require 'active_support/core_ext/numeric/time'

module Travis::GuestAPI
  # Remembers steps by their jobs so that
  # they can be  provided in route GET steps/:uuid
  # for backward compatibility.
  class Cache
    def initialize(max_job_time = 24.hours, gc_polling_interval = 1.hour)
      @cache = {}
      @max_job_time = max_job_time
      @mutex = Mutex.new
      initialize_garbage_collector gc_polling_interval
    end

    def initialize_garbage_collector(polling_interval)
      @thread = Thread.new do
        begin
          loop do
            Travis.logger.debug "Next step cache GC in #{polling_interval} seconds."
            sleep polling_interval.to_i # fails in jruby without to_i
            gc
          end
        rescue StandardError => e
          Travis.logger.error "Step Cache GC exploded: #{e.class}: #{e.message}"
          raise e
        end
      end
    end

    def set(job_id, step_uuid, result)
      fail ArgumentError, 'Parameter "result" must be a hash' unless
        result.is_a?(Hash)

      @mutex.synchronize do
        @cache[job_id] ||= {}
        @cache[job_id][:last_time_used] = Time.now
        @cache[job_id][step_uuid] ||= {}
        @cache[job_id][step_uuid].deep_merge!(result)
      end

      @cache[job_id][step_uuid]
    end

    def get(job_id, step_uuid)
      return nil unless @cache[job_id]
      @cache[job_id][:last_time_used] = Time.now
      @cache[job_id][step_uuid]
    end

    def get_result(job_id)
      return 'started' unless @cache[job_id]
      result = 'passed'
      @cache[job_id].each do |key, step_result|
        next if key == :last_time_used
        if step_result['result'].to_s.downcase == 'failed'
          result = 'failed'
          break
        end
      end
      result
    end

    def exists?(job_id)
      return !!@cache[job_id]
    end

    def delete(job_id)
      @mutex.synchronize do
        Travis.logger.info "Deleting #{job_id} from cache"
        @cache.delete job_id
      end
    end

    def gc
      Travis.logger.debug 'Starting cache garbage collector'
      expired_time = Time.now - @max_job_time
      Travis.logger.debug expired_time.to_s
      @cache.keys.each do |job_id|
        delete(job_id) if @cache[job_id][:last_time_used] < expired_time
      end
      Travis.logger.debug 'Garbage collector finished'
    end

    # Use only if you will never ever use this class again
    #
    def finalize
      @mutex.synchronize do
        Thread.kill(@thread) if @thread
        @cache = {}
      end
    end

    private :initialize_garbage_collector, :gc
  end
end
