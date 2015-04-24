require 'nokogiri'

Travis::Database.connect

class JUnitParser

  class TestCaseNode
    TestCase = Struct.new(:test_data, :result, :name, :classname, :duration)

    attr_reader :node, :test_case
    def initialize(node)
      @node = node
      @test_case = TestCase.new({}, 'success')
    end

    def parse
      test_case.name = node['name']
      test_case.classname = node['classname'] if node['classname']
      test_case.duration = node['time'].to_f * 1000 if node['time']

      stdout_node = node.at('system-out')
      test_case.test_data[:stdout] = stdout_node.text if stdout_node

      stderr_node = node.at('system-err')
      test_case.test_data[:stdout] = stderr_node.text if stderr_node

      node.xpath('error|failure').each do |ex|
        parse_exception(ex)
      end

      self
    end

    def parse_exception(ex)
      test_case.result = ex.name
      test_case.test_data[:message] = ex['message']
    end

    def to_h
      res = Hash[test_case.each_pair.to_a]
      res.delete :test_data if res[:test_data].nil? or res[:test_data].empty?
      res
    end
  end


  attr_reader :doc, :job_id

  def initialize(file_or_io, job_id)
    @doc = Nokogiri::XML(file_or_io)
    @job_id = job_id
  end

  def parse
    doc.xpath('//testsuite').each do |testsuite|

      #TODO: TestSuite & properties are not stored yet
      test_suite_name = testsuite['name']
      properties = {}
      testsuite.xpath('properties/property').each do |property|
        properties[property['name']] = property['value']
      end

      testsuite.xpath('testcase').each do |test_case_node|
        test_case = TestCaseNode.new(test_case_node).parse.to_h
        yield(test_case.update(job_id: job_id))
        #e.g.: TestStepResult.write_result(test_case.update(job_id: job_id))
      end
    end
  end
end

__END__
$: << './lib'
require 'bundler/setup'
require 'travis'

xml_str = File.open('tmp/rspec.xml')
#xml_str = File.open('tmp/failed_example.xml')

junit_parser = JUnitParser.new(xml_str, 1)
junit_parser.parse do |testcase|
  #STDERR.puts testcase.inspect
  TestStepResult.write_result(testcase)
end
