#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../', 'application', 'service.rb')

module MCollective
  class Application
    describe Service do
      before do
        application_file = File.join(File.dirname(__FILE__), '../../', 'application', 'service.rb')
        @app = MCollective::Test::ApplicationTest.new('service', :application_file => application_file).plugin
      end

      describe '#application_description' do
        it 'should have a descriptionset' do
          @app.should have_a_description
        end
      end

      describe '#handle_message' do
        it 'should call the display action with the correct message' do
          @app.expects(:print).with("Please specify service name and action")
          @app.expects(:print).with("Action has to be one of start, stop, restart or status")
          @app.expects(:print).with("Do you really want to operate on services unfiltered? (y/n): ")
          @app.handle_message(:print, 1)
          @app.handle_message(:print, 2)
          @app.handle_message(:print, 3)
        end
      end

      describe '#validate_configuration' do
        before do
          MCollective::Util.stubs(:empty_filter?).returns(true)
          @app.stubs(:options).returns({:filter =>{}})
          @app.stubs(:handle_message).with(:print, 3)
          STDOUT.stubs(:flush)
        end

        it 'should ask confirmation if filter is unset and exit if not given' do
          STDIN.stubs(:gets).returns('n')
          @app.expects(:exit).with(1)
          @app.validate_configuration({})
        end

        it 'should ask confirmation if filter is unset and return if given' do
          STDIN.stubs(:gets).returns('y')
          @app.expects(:exit).with(1).never
          @app.validate_configuration({})
        end

        it 'should not ask confirmation if filter is unset if action is status' do
          @app.expects(:handle_message).with(:print,3).never
          MCollective::Util.expects(:empty_filter?).never
          @app.validate_configuration({:action => 'status'})
        end
      end

      describe '#post_option_parser' do
        it 'should fail if service and action are not supplied' do
          @app.expects(:handle_message).with(:raise, 1)
          @app.post_option_parser({})
        end

        it 'should fail if an unknown action is supplied' do
          @app.expects(:handle_message).with(:raise, 2)
          ARGV << 'rspec'
          ARGV << 'rspec'
          @app.post_option_parser({})
        end

        it 'should parse "action" "service" correctly' do
          config = {}
          ARGV << 'start'
          ARGV << 'rspec'
          @app.post_option_parser(config)
          config[:action].should == 'start'
          config[:service].should == 'rspec'
        end

        it 'should parser "service" "action" correctly' do
          config = {}
          ARGV << 'rspec'
          ARGV << 'start'
          @app.post_option_parser(config)
          config[:action].should == 'start'
          config[:service].should == 'rspec'
        end
      end

      describe '#main' do
        let(:rpcclient) { mock }

        before do
          @app.expects(:rpcclient).returns(rpcclient)
        end

        it 'should display the correct output for the start action' do
          resultset = [{:data => {:exitcode => 0,:status => 'running'},:statuscode => 0,:sender => 'rspec'}]
          @app.configuration[:action] = 'start'
          @app.configuration[:service] = 'rspec'
          rpcclient.expects(:send).with('start', :service => 'rspec').returns(resultset)
          rpcclient.stubs(:verbose).returns(false)
          rpcclient.stubs(:stats)
          @app.expects(:halt)
          @app.main
        end

        it 'should display the correct output for the stop action' do
          resultset = [{:data => {:exitcode => 0,:status => 'stopped'},:statuscode => 0,:sender => 'rspec'}]
          @app.configuration[:action] = 'stop'
          @app.configuration[:service] = 'rspec'
          rpcclient.expects(:send).with('stop', :service => 'rspec').returns(resultset)
          rpcclient.stubs(:verbose).returns(false)
          rpcclient.stubs(:stats)
          @app.expects(:halt)
          @app.main
        end

        it 'should display the correct output for the status action' do
          resultset = [{:data => {:exitcode => 0,:status => 'running'},:statuscode => 0,:sender => 'rspec'}]
          @app.configuration[:action] = 'status'
          @app.configuration[:service] = 'rspec'
          rpcclient.expects(:send).with('status', :service => 'rspec').returns(resultset)
          rpcclient.stubs(:verbose).returns(false)
          rpcclient.stubs(:stats)
          @app.expects(:puts).with("%8s: %s" % ['rspec', 'running'])
          @app.expects(:halt)
          @app.main
        end

        it 'should display the correct output when verbose is set' do
          resultset = [{:data => {:exitcode => 0,:status => 'stopped'},:statuscode => 0,:sender => 'rspec', :statusmsg => 'OK'}]
          @app.configuration[:action] = 'stop'
          @app.configuration[:service] = 'rspec'
          rpcclient.expects(:send).with('stop', :service => 'rspec').returns(resultset)
          rpcclient.stubs(:verbose).returns(true)
          rpcclient.stubs(:stats)
          @app.expects(:puts).with("%8s: %s" % ['rspec', 'stopped'])
          @app.expects(:halt)
          @app.main
        end
      end
    end
  end
end
