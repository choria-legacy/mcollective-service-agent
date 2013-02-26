#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../', 'agent', 'service.rb')
require File.join(File.dirname(__FILE__), '../../', 'util', 'service', 'base.rb')

module MCollective
  module Agent
    describe Service do

      before do
        agent_file = File.join(File.dirname(__FILE__), '../../', 'agent', 'service.rb')
        @agent = MCollective::Test::LocalAgentTest.new('service', :agent_file => agent_file).plugin
      end

      describe '#start' do
        it "should call #do_service_action with 'start'" do
          Service.expects(:do_service_action).with('start', 'rspec').returns({:status => 'running'})
          result = @agent.call(:start, :service => 'rspec')
          result.should be_successful
          result.should have_data_items(:status => 'running')
        end

        it "should call raise an exception and set status if result hash includes the msg key" do
          Service.expects(:do_service_action).with('start', 'rspec').returns({:status => 'running', :msg => "error"})
          result = @agent.call(:start, :service => 'rspec')
          result.should be_aborted_error
          result.should have_data_items(:status => 'running')
        end
      end

      describe '#stop' do
        it "should call #do_service_action with 'stop'" do
          Service.expects(:do_service_action).with('stop', 'rspec').returns({:status => 'stopped'})
          result = @agent.call(:stop, :service => 'rspec')
          result.should be_successful
          result.should have_data_items(:status => 'stopped')
        end

        it "should call raise an exception and set status if result hash includes the msg key" do
          Service.expects(:do_service_action).with('start', 'rspec').returns({:status => 'running', :msg => "error"})
          result = @agent.call(:start, :service => 'rspec')
          result.should be_aborted_error
          result.should have_data_items(:status => 'running')
        end
      end

      describe '#restart' do
        it "should call #do_service_action with 'restart'" do
          Service.expects(:do_service_action).with('restart', 'rspec').returns('running')
          result = @agent.call(:restart, :service => 'rspec')
          result.should be_successful
          result.should have_data_items(:status => 'running')
        end

        it 'should set status to unknown on failure' do
          Service.expects(:do_service_action).with('restart', 'rspec').raises("rspec error")
          result = @agent.call(:restart, :service => 'rspec')
          result.should be_unknown_error
          # Confirm that status field has not been set. This means that status will be assigned
          # to the default value defined in the ddl
          result[:data][:status].should be_nil
        end
      end

      describe '#status' do
        it "should call #do_service_action with 'status'" do
          Service.expects(:do_service_action).with('status', 'rspec').returns('stopped')
          result = @agent.call(:status, :service => 'rspec')
          result.should be_successful
          result.should have_data_items(:status => 'stopped')
        end
      end

      describe '#do_service_action' do
        let(:provider){mock}

        before :each do
          PluginManager.expects(:loadclass).with('MCollective::Util::Service::Base')
          provider.stubs(:new).returns(provider)
        end

        it 'should load the default service provider and call an action' do
          PluginManager.expects(:loadclass).with('MCollective::Util::Service::PuppetService')
          Util::Service.expects(:const_get).with("PuppetService").returns(provider)
          provider.expects(:send).with('start')

          Service.do_service_action('start', 'rspec')
        end

        it 'should load the service provider from config and call an action' do
          @agent.config.stubs(:pluginconf).returns({'service.provider' => 'rspec'})
          PluginManager.expects(:loadclass).with('MCollective::Util::Service::RspecService')
          Util::Service.expects(:const_get).with("RspecService").returns(provider)
          provider.expects(:send).with('start')

          Service.do_service_action('start', 'rspec')
        end

        it 'should fail if the provider cannot be loaded' do
          PluginManager.expects(:loadclass).with('MCollective::Util::Service::PuppetService').raises(LoadError)
          expect{
            Service.do_service_action('restart', 'rspec')
          }.to raise_error(/Cannot load service provider/)
        end
      end
    end
  end
end
