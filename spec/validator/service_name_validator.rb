#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../', 'validator', 'service_name.rb')

module MCollective
  module Validator
    describe Service_nameValidator do
      describe '#validate' do
        it 'should validate a valid service name' do
          Service_nameValidator.validate('rspec')
          Service_nameValidator.validate('rspec1')
          Service_nameValidator.validate('rspec-service')
          Service_nameValidator.validate('rspec-service-1')
          Service_nameValidator.validate('rspec.service')
        end
        it 'should fail on a invalid service name' do
          expect{
            Service_nameValidator.validate('rspec!')
          }.to raise_error
        end
      end
    end
  end
end
