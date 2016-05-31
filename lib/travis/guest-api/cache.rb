require 'active_support/core_ext/numeric/time'
require 'redis'

module Travis::GuestAPI
  # Remembers steps by their jobs so that
  # they can be  provided in route GET steps/:uuid
  # for backward compatibility.
  class Cache
    def initialize(max_job_time = 24.hours)
      @max_job_time = max_job_time
      @mutex = Mutex.new
      @redis = Redis.new
    end

    def set(job_id, step_uuid, result)
      fail ArgumentError, 'Parameter "result" must be a hash' unless
        result.is_a?(Hash)
      job_record = {}
      @mutex.synchronize do
        job_string = @redis.get(job_id)
        job_record = JSON.parse(job_string) if job_string
        job_record[step_uuid] ||= {}
        job_record[step_uuid].deep_merge!(result)
        @redis.set(job_id, job_record.to_json)
        @redis.expire(job_id, @max_job_time)
      end

      job_record[step_uuid]
    end

    def get(job_id, step_uuid)
      job_string = @redis.get(job_id)
      return nil unless job_string
      job_record = JSON.parse(job_string)
      job_record[step_uuid]
    end

    def get_result(job_id)
      job_string = @redis.get(job_id)
      return 'errored' unless job_string
      job_record = JSON.parse(job_string)
      result = 'passed'
      job_record.each do |key, step_result|
        if step_result['result'].to_s.downcase == 'failed'
          result = 'failed'
          break
        end
      end
      result
    end

    def exists?(job_id)
      result = @redis.get(job_id)
      !result.nil?
    end

    def delete(job_id)
      @mutex.synchronize do
        Travis.logger.info "Deleting #{job_id} from cache"
        @redis.del job_id
      end
    end

    # Use only if you will never ever use this class again
    #
    def finalize
      @mutex.synchronize do
        Thread.kill(@thread) if @thread
        @redis.flushdb
      end
    end
  end
end
