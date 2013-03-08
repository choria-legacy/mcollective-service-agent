metadata :name => "service",
         :description => "Checks the status of a service",
         :author => "Pieter Loubser <pieter.loubser@puppetlabs.com>",
         :license => "ASL 2.0",
         :version => "2.0.1",
         :url => "http://projects.puppetlabs.com/projects/mcollective-plugins/wiki",
         :timeout => 3

requires :mcollective => "2.2.1"

usage <<-END_OF_USAGE
Checks the status of a service. This plugin can be used during discovery and everywhere else
the mcollective discovery language is used.

Example Usage:

  During Discovery -  mco rpc rpcutil ping -S "service('puppet').status=running"
  Action Policy    -  service('puppet').status=stopped

END_OF_USAGE

dataquery :description => "Service" do
    input :query,
          :prompt => "Service Name",
          :description => "Service Name",
          :type => :string,
          :validation => :service_name,
          :maxlength => 50

    output :status,
           :description => "stopped/running",
           :display_as => "Service Status"
end
