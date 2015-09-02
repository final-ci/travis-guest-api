require 'spec_helper'
require 'travis/guest-api/cache'
require 'travis/support'
require 'active_support/core_ext/numeric/time'
require 'timeout'

describe Travis::GuestAPI::Cache do
  let(:max_job_time) { 5.minutes }
  let(:gc_polling_interval) { 5.minutes }
  let(:cache) { Travis::GuestAPI::Cache.new max_job_time, gc_polling_interval }
  let(:test_uuid) { 'ffdec891-ac4d-4187-a228-3edbe474c775' }

  after(:each) { cache.finalize }

  describe '#set' do
    it 'persists given value' do
      job_id = 42
      result = { foo: 'test result' }
      cache.set job_id, test_uuid, result
      expect(cache.get job_id, test_uuid).to eq result
    end

    it 'throws when result is not a hash' do
      expect do
        cache.set 42, test_uuid, 'not a hash'
      end.to raise_error ArgumentError
    end
  end

  describe '#get' do
    context 'record time to live expired' do
      let(:max_job_time) { 0 }
      let(:gc_polling_interval) { 0 }

      it 'returns Nil' do
        job_id = 666
        cache.set job_id, test_uuid, foo: 'bar'
        sleep 0.1
        expect(cache.get job_id, test_uuid).to be_nil
      end
    end

    context 'record alive' do
      it 'returns record' do
        job_id = 666
        record = { foo: 'bar' }
        cache.set job_id, test_uuid, record
        expect(cache.get job_id, test_uuid).to eq record
      end
    end
  end

  describe '#delete' do
    it 'deletes specified record' do
      job_id = 666
      cache.set job_id, test_uuid, foo: 'bar'
      cache.delete job_id
      expect(cache.get job_id, test_uuid).to be_nil
    end
  end
end
