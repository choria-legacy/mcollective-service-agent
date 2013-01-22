#!/usr/bin/evn rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../../', 'util', 'service', 'base.rb')

module MCollective
  module Util
    module Service
      describe Base do
        let(:base) { Base.new('rspec', {:key1 => 'val1', :key2 => 'val2'}) }

        describe "#initialize" do
          it 'should set the correct options hash' do
            base.options.should == {:key1 => 'val1', :key2 => 'val2'}
          end
        end

        describe "#start" do
          it 'should fail to start' do
            expect{
              base.start
            }.to raise_error("error. MCollective::Util::Service::Base Does not implement #start")
          end
        end

        describe "#stop" do
          it 'should fail to stop' do
            expect{
              base.stop
            }.to raise_error("error. MCollective::Util::Service::Base Does not implement #stop")
          end
        end

        describe "#restart" do
           it 'should fail to restart' do
            expect{
              base.restart
            }.to raise_error("error. MCollective::Util::Service::Base Does not implement #restart")
          end
        end

        describe "#status" do
           it 'should fail to display status' do
            expect{
              base.status
            }.to raise_error("error. MCollective::Util::Service::Base Does not implement #status")
          end
        end
      end
    end
  end
end
