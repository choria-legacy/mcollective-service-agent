metadata :name => "service_name",
         :description => "Validates that a string is a service name",
         :author => "P. Loubser <pieter.loubser@puppetlabs.com>",
         :license => "ASL 2.0",
         :version => "1.0.0",
         :url => "http://projects.puppetlabs.com/projects/mcollective-plugins/wiki",
         :timeout => 1

requires :mcollective => "2.2.1"

usage <<-END_OF_USAGE
Validates if a given string is a valid service name.

In a DDL :
  validation => :service_name

In code :
   MCollective::Validator.validate("puppet", :service_name)

END_OF_USAGE
