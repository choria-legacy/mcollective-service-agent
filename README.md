# Service Agent

## Deprecation Notice

This repository holds legacy code related to The Marionette Collective project.  That project has been deprecated by Puppet Inc and the code donated to the Choria Project.

Please review the [Choria Project Website](https://choria.io) and specifically the [MCollective Deprecation Notice](https://choria.io/mcollective) for further information and details about the future of the MCollective project.

## Overview

The service agent that lets you stop, start, restart and query the statuses of services on your operating system.

The service agent does not do any management of services itself. Instead it
uses the functionality defined in MCollective::Util::Service classes to
perform the actions. By default the Service agent ships with a PuppetService
util class, but creating your own is as simple as adding a new class to
util/service/ and implementing the start, stop, status and restart methods.

## Installation

Follow the [basic plugin install guide](http://projects.puppetlabs.com/projects/mcollective-plugins/wiki/InstalingPlugins).

## Configuration

There is one plugin configuration setting for the service agent.

* provider   - The Util class that implements the start, stop, restart and status behavior. Defaults to 'puppet'

General provider configuration options can then also be set in the config file.

```
plugin.service.provider = puppet

# Puppet provider specific options
plugin.service.puppet.hasstatus = true
plugin.service.puppet.hasrestart = true

```

## Usage
```
% mco rpc service status service=httpd -W /dev_server/
Determining the amount of hosts matching filter for 2 seconds .... 4

 * [ ============================================================> ] 4 / 4

Summary of Service Status:

   running = 3
   stopped = 1


Finished processing 4 / 4 hosts in 241.49 ms
```

```
% mco service puppet stop
Do you really want to operate on services unfiltered? (y/n): y

 * [ ============================================================> ] 4 / 4


Summary of Service Status:

   stopped = 4


Finished processing 4 / 4 hosts in 909.01 ms
```

## Data Plugin

The Service agent also supplies a data plugin which uses the Service agent to
check the current status of a service. The data plugin will return 'running'
or 'stopped' and can be used during discovery or any other place where the
MCollective discovery language is used.

```
mco rpc rpcutil ping -S "service('myservice').status=running"
```

## Validator

The Service agent also supplies a validator plugin that will validate if a
given string is a valid service name.

```
validate :service, :service_name
```

## Extending

The default service agent achieves platform portability by using the Puppet
provider system to support service managers on all platforms that Puppet
supports.

If however you are not a Puppet user or simply want to implement some new
method of service management you can do so by providing your own backend
provider for this agent.

A `service` provider that uses the `service` system command has also been
contributed; it can be configured to work with any command that responds to
`mycommand myservice start/stop/restart/status`.

The logic for the Puppet version of this agent is implemented in
Util::Service::PuppetService, you can create a custom service implementation
that overrides #start, #stop, #restart, and #status.

To provide compatibility with the service data plugin #status should return
'stopped' if the service is stopped, and 'running' if the service is running.

This agent defaults to Util::Service::PuppetService but if you have your own
you can configure it in the config file using:

```
plugin.service.provider = puppet
```
