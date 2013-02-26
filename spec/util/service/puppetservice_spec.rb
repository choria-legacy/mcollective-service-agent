#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../../', 'agent', 'service.rb')
require File.join(File.dirname(__FILE__), '../../../', 'util', 'service', 'base.rb')
require File.join(File.dirname(__FILE__), '../../../', 'util', 'service', 'puppetservice.rb')

module MCollective
  module Util
    module Service
      describe PuppetService do
        let(:service) { PuppetService.new('rspec', {:key => "value"}) }
        let(:svc){mock}

        before do
          PuppetService.any_instance.stubs(:require)
          service.stubs(:service_provider).returns(svc)
        end

        describe '#stop' do
          it 'should stop the service' do
            svc.expects(:status).returns('running')
            svc.expects(:stop)
            service.expects(:properties).returns('stopped')
            result = service.stop
            result.should == {:status => 'stopped', :msg => nil}
          end

          it 'should return stopped and a failure message if service is already stopped' do
            service.stubs(:status).returns('stopped')
            service.expects(:properties).returns('stopped')
            svc.expects(:stop).never
            service.stop.should == {:status => 'stopped', :msg => "Could not stop 'rspec': Service is already stopped"}
          end
        end

        describe '#start' do
          it 'should start the service' do
            svc.expects(:status).returns('stopped')
            svc.expects(:start)
            service.expects(:properties)
            service.start
          end

          it 'should return running and a failure message if service is already running' do
            service.stubs(:status).returns('running')
            service.expects(:properties).returns('running')
            svc.expects(:start).never
            service.start.should == {:status => 'running', :msg => "Could not start 'rspec': Service is already running"}
          end
        end

        describe '#restart' do
          it 'should restart the service if hasrestart is true' do
            svc.expects(:restart)
            service.expects(:properties)
            service.restart
          end

          it 'should raise an exception if trying to restart and hasrestart is false' do
            expect{
              failed_service.restart
            }.to raise_error
          end
        end

        describe '#status' do
          it 'should return the status of the service' do
            svc.expects(:status).returns('status')
            service.status
          end

          it 'should raise an exception when calling status and hasstatus is false' do
            expect{
              failed_servce.status
            }.to raise_error
          end
        end

        describe '#service_provider' do
          class Puppet;class Type;end;end
          it 'should create a puppet provider once' do
            service.unstub(:service_provider)

            provider = mock
            provider.expects(:start).twice

            type = mock
            type.expects(:new).returns(type).once
            type.expects(:provider).returns(provider).once
            Puppet::Type.expects(:type).returns(type).once

            service.stubs(:status)
            service.stubs(:properties)
            service.start
            service.start
          end
        end

        describe '#properties' do
          it 'should sleep for 0.5 seconds and return the status' do
            svc.stubs(:start)
            service.expects(:sleep).with(0.5)
            service.stubs(:status)
            service.start
        end
      end
    end
  end
end
  end
