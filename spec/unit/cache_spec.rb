require 'spec_helper'
require 'travis/guest-api/cache'
require 'travis/support'
require 'active_support/core_ext/numeric/time'
require 'timeout'

describe Travis::GuestAPI::Cache do
  let(:max_job_time) { 5.minutes }
  let(:gc_polling_interval) { 5.minutes }
  let(:cache) { Travis::GuestAPI::Cache.new max_job_time, gc_polling_interval }

  describe '#set' do
    it 'persists given value' do
      job_id = 42
      step_uuid = SecureRandom.uuid
      result = { foo: 'test result' }
      cache.set job_id, step_uuid, result
      expect(cache.get job_id, step_uuid).to eq result
    end

    it 'throws when result is not a hash' do
      set_wrong_result = -> { cache.set 42, SecureRandom.uuid, 'not a hash' }
      expect { set_wrong_result.call }.to raise_error ArgumentError
    end
  end

  describe '#get' do
    context 'record time to live expired' do
      let(:max_job_time) { 0 }
      let(:gc_polling_interval) { 0 }

      it 'returns Nil' do
        job_id = 666
        step_uuid = SecureRandom.uuid
        cache.set job_id, step_uuid, foo: 'bar'
        timeout(5) do
          sleep 0.001 until cache.get(job_id, step_uuid).nil?
        end
        expect(cache.get job_id, step_uuid).to be_nil
      end
    end

    context 'record alive' do
      it 'returns record' do
        job_id = 666
        step_uuid = SecureRandom.uuid
        record = { foo: 'bar' }
        cache.set job_id, step_uuid, record
        expect(cache.get job_id, step_uuid).to eq record
      end
    end
  end

  describe '#delete' do
    it 'deletes specified record' do
      job_id = 666
      step_uuid = SecureRandom.uuid
      cache.set job_id, step_uuid, foo: 'bar'
      cache.delete job_id
      expect(cache.get job_id, step_uuid).to be_nil
    end
  end
end
