#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../', 'data', 'service_data.rb')
require File.join(File.dirname(__FILE__), '../../', 'agent', 'service.rb')

module MCollective
  module Data
    describe Service_data do
      describe '#query_data' do
        let(:plugin){Service_data.new}

        before do
          @ddl = mock('ddl')
          @ddl.stubs(:dataquery_interface).returns({:output => {}})
          @ddl.stubs(:meta).returns({:timeout => 1})
          DDL.stubs(:new).returns(@ddl)
        end

        it 'should show running if the service is running' do
          Agent::Service.expects(:do_service_action).with('status', 'rspec').returns('running')
          plugin.query_data('rspec').should == 'running'
        end

        it 'should show stopped if the service is stopped' do
          Agent::Service.expects(:do_service_action).with('status', 'rspec').returns('stopped')
          plugin.query_data('rspec').should == 'stopped'
        end

        it 'should display an error message if agent status cannot be determined' do
          Agent::Service.expects(:do_service_action).with('status', 'rspec').raises('error')
          MCollective::Log.expects(:warn).with("Could not get status for service rspec: error")
          plugin.query_data('rspec')
        end
      end
    end
  end
end
