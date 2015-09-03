require 'spec_helper'
require 'ostruct'
require 'rack/test'

module Travis::GuestApi
  describe App do
    include Rack::Test::Methods

    def app
      Travis::GuestApi::App.new(1, reporter, &callback)
    end

    def create_step(step)
      expect(reporter).to receive(:send_tresult)
      post '/api/v2/steps',
           step.to_json,
           'CONTENT_TYPE' => 'application/json'
      (JSON.parse last_response.body)['uuid']
    end

    let(:reporter) { double(:reporter) }
    let(:callback) { ->(_) {} }

    context 'testcase' do
      let(:testcase) {
        {
          'job_id'    => 1,
          'name'      => 'stepName1',
          'classname' => 'caseName1',
          'result'    => 'success'
        }
      }

      let(:testcase_with_data) {
        {
          'name'      => 'stepName2',
          'classname' => 'caseName2',
          'result'    => 'success',
          'test_data' => { 'any_content' => 'xxx' },
          'duration' => 56
        }
      }

      describe 'POST /steps' do
        it 'sends data to the reporter' do
          expect(reporter).to receive(:send_tresult) { |job_id, arg|
            expect(arg.count).to eq(1)
            expect(job_id).to eq(testcase['job_id'])
            e = testcase.dup
            e.delete 'job_id'
            expect(arg[0]['uuid']).to be_a(String)
            e['uuid'] = arg[0]['uuid']
            expect(arg[0]).to eq(e)
          }
          expect(reporter).to receive(:send_tresult) { |job_id, arg|
            e = testcase_with_data.dup
            e.delete 'job_id'
            arg[0].delete 'uuid'
            expect(arg[0]).to eq(e)
          }

          response = post '/api/v2/steps', testcase.to_json, "CONTENT_TYPE" => "application/json"
          expect(response.status).to eq(200)

          response = post '/api/v2/steps', testcase_with_data.to_json, "CONTENT_TYPE" => "application/json"
          expect(response.status).to eq(200)
        end

        it 'responds with 422 when name, classname is missing' do
          without_name = testcase.dup
          without_name.delete 'name'
          response = post '/api/v2/steps', without_name.to_json, "CONTENT_TYPE" => "application/json"
          expect(response.status).to eq(422)

          without_classname = testcase.dup
          without_classname.delete 'classname'
          response = post '/api/v2/steps', without_classname.to_json, "CONTENT_TYPE" => "application/json"
          expect(response.status).to eq(422)
        end

        it 'generates step uuid' do
          expect(reporter).to receive(:send_tresult)
          post '/api/v2/steps',
               testcase.to_json,
               'CONTENT_TYPE' => 'application/json'
          expect(JSON.parse last_response.body).to include('uuid')
        end

        context 'bulk update' do
          it 'sends several record to the reporter' do
            request = [
              testcase,
              testcase_with_data
            ]
            expect(reporter).to receive(:send_tresult) { |job_id, arg|
              expect(arg.count).to eq(2)
              expect(job_id).to eq(testcase['job_id'])
              e = testcase.dup
              expect(arg[0]['uuid']).to be_a(String)
              expect(arg[1]['uuid']).to be_a(String)

              expect(arg[0]['name']).to eq('stepName1')
              expect(arg[1]['name']).to eq('stepName2')

              expect(arg[0]['classname']).to eq('caseName1')
              expect(arg[1]['classname']).to eq('caseName2')

              expect(arg[1]['duration']).to eq(56)
            }
            post '/api/v2/steps', request.to_json, "CONTENT_TYPE" => "application/json"
            expect(last_response.status).to eq(200)
          end

        end
      end

      describe 'POST /jobs/:job_id/steps' do
        it 'responds with 422 when passed job_id is wrong' do
          response = post '/api/v1/jobs/2/steps', testcase.to_json, "CONTENT_TYPE" => "application/json"
          expect(response.status).to eq(422)
        end
      end

      describe 'GET /steps/:step_uuid' do
        it 'returns previously created step' do
          step_uuid = create_step(testcase)
          get "/api/v2/steps/#{step_uuid}"
          response_body = JSON.parse last_response.body
          expected_testcase = testcase.dup
          expected_testcase.delete 'job_id'
          expected_testcase['uuid'] = step_uuid
          expect(response_body).to eq expected_testcase
        end

        it 'returns 403 if step does not exist' do
          get 'api/v2/steps/i_made_it_up'
          expect(last_response.status).to eq 403
        end
      end

      describe 'PUT /steps/:uuid?' do
        it 'modifies existing step' do
          step_uuid = create_step(testcase)
          update_request = { result: 'updated result' }
          expect(reporter).to receive(:send_tresult_update)
          put "/api/v2/steps/#{step_uuid}",
              update_request.to_json,
              'CONTENT_TYPE' => 'application/json'
          expected_testcase = testcase.dup
          expected_testcase.delete 'job_id'
          expected_testcase['result'] = update_request[:result]
          expected_testcase['uuid'] = step_uuid
          expect(last_response.status).to eq 200
          expect(JSON.parse last_response.body).to eq expected_testcase
        end

        it 'returns 403 when updating name' do
          step_uuid = create_step(testcase)
          update_request = { name: 'new name' }
          put "/api/v2/steps/#{step_uuid}",
              update_request.to_json,
              'CONTENT_TYPE' => 'application/json'
          expect(last_response.status).to eq 403
        end

        it 'returns 403 when updating classname' do
          step_uuid = create_step(testcase)
          update_request = { classname: 'new classname' }
          put "/api/v2/steps/#{step_uuid}",
              update_request.to_json,
              'CONTENT_TYPE' => 'application/json'
          expect(last_response.status).to eq 403
        end

        it 'returns 403 if step does not exist' do
          put '/api/v2/steps/i_dont_exist',
              testcase.to_json,
              'CONTENT_TYPE' => 'application/json'
          expect(last_response.status).to eq 403
        end

        context 'bulk update' do
          let(:testcase1) {
            { 'name' => 'stepName1', 'classname' =>  'testCaseName1' }
          }
          let(:testcase2) {
            { 'name' => 'stepName2', 'classname' =>  'testCaseName2' }
          }
          it 'updates several steps' do
            step_uuid1 = create_step(testcase1)
            step_uuid2 = create_step(testcase2)
            update_request = [
              { 'uuid' => step_uuid1, 'result' => 'success' },
              { 'uuid' => step_uuid2, 'result' => 'failed' }
            ]

            expect(reporter).to receive(:send_tresult_update) do |job_id, arg|
              expect(arg.count).to eq 2
              expect(arg[0]['uuid']).to eq step_uuid1
              expect(arg[0]['result']).to eq 'success'
              expect(arg[1]['uuid']).to eq step_uuid2
              expect(arg[1]['result']).to eq 'failed'
            end

            put "/api/v2/steps",
                update_request.to_json,
                'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq 200
            expect(JSON.parse last_response.body).to eq [
              testcase1.update(update_request[0]),
              testcase2.update(update_request[1])
            ]
          end
        end
      end
    end
  end
end
