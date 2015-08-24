require 'active_support/core_ext/numeric/time'

module Travis::GuestAPI
  # Remembers steps so that they can be
  # provided in route GET steps/:uuid
  # for backward compatibility.
  class Cache
    def initialize(max_job_time = 24.hours, gc_polling_interval = 1.hour)
      @cache = {}
      @max_job_time = max_job_time
      @mutex = Mutex.new

      gc_thread = Thread.new do
        loop do
          puts "Next GC in #{gc_polling_interval} seconds."
          sleep gc_polling_interval.to_i # fails in jruby without to_i
          gc
        end
      end
      gc_thread.abort_on_exception = true
    end

    def set(job_id, step_uuid, result)
      fail ArgumentError, 'Parameter "result" must be a hash' unless
        result.is_a?(Hash)

      @mutex.synchronize do
        @cache[job_id] ||= {}
        @cache[job_id][:last_time_used] = Time.now
        @cache[job_id][step_uuid] ||= {}
        @cache[job_id][step_uuid].update(result)
      end
    end

    def get(job_id, step_uuid)
      return nil unless @cache[job_id]
      @cache[job_id][:last_time_used] = Time.now
      @cache[job_id][step_uuid]
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
  end
end
