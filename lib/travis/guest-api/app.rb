require 'travis'
require 'travis/model'
require 'travis/support/amqp'
#require 'travis/states_cache'
#require 'rack'
#require 'rack/contrib'
#require 'rack/cache'
require 'active_record'
#require 'redis'
#require 'sidekiq'

#require 'metriks/reporter/logger'
#require 'metriks/librato_metrics_reporter'
#require 'travis/support/log_subscriber/active_record_metrics'

require 'sinatra/base'


Travis::Database.connect
ActiveRecord::Base.logger = Travis.logger

if Travis.env == 'production'
   Travis::LogSubscriber::ActiveRecordMetrics.attach
   Travis::Notification.setup(instrumentation: false)
   Travis::Metrics.setup

   #TODO: Amqp setup
end


module Travis::GuestApi
  class App < Sinatra::Base
    before do
      env['rack.logger'] = Travis.logger
      env['rack.errors'] = Travis.logger.instance_variable_get(:@logdev).dev rescue nil
    end

    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    use ActiveRecord::QueryCache

    use Rack::Deflater

    post 'jobs/:job_id/log' do
      content_type :json
      payload = JSON.parse(request.body.read).slice('job_id', 'log_message', 'number').symbolize_keys

      if payload[:job_id] and payload[:log_message]
        Travis.run_service(:push_log, payload)
        halt 200
      else
        halt 422, { error: "Keys :job_id, :log_message and number must be passed" }
      end
    end

    post '/jobs/:job_id/testcases' do
      content_type :json
      payload = JSON.parse(request.body.read).symbolize_keys

      payload = payload.slice(:job_id, :name, :classname, :test_data)

      TestStepResult.write_result(test_case)
    end

    get  '/jobs/:job_id/testcases/:testcase_uuid' do
      content_type :json
      payload = JSON.parse(request.body.read).symbolize_keys

      step = TestStepResult.joins(:test_case_result).
        where(id: payload[:testcase_id], :'test_case_results.job_id' => payload[:job_id]).first

      halt(step ? step.attributes.to_json : 404)
    end

    put  '/jobs/:job_id/testcases/:testcase_uuid' do
    end

    post '/jobs/:job_id/testcases/upload' do
    end

    # @params
    #   ssh = keep_disconnected, retry_on_disconnect
    put '/jobs/:job_id/communication' do
    end

    post '/jobs/:job_id/restart' do
    end

    post '/jobs/:job_id/finished' do
    end

    run! if app_file == $0
  end
end
