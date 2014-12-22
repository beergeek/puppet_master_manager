# puppet_master_manager

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with puppet_master_manager](#setup)
    * [What puppet_master_manager affects](#what-puppet_master_manager-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet_master_manager](#beginning-with-puppet_master_manager)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A module to manage active/passive master pair in PE3.7.1.

## Module Description

Module setups incrond and Postgresql dumps on Active.

Module manages certificates on Passive.

## Setup

### What puppet_master_manager affects

* incrond and job on Active
* Cron jobs for Postgresql dump on Active
* Classifier, Dashbaord and Postgresql certs on Passive

### Setup Requirements

#### Active Master

Perform an all-in-one installation via an answers file.

#### Passive Master

Copy the Active Master's answers file to the Passive Master.
Replace all instances of the Active Master's hostname with the Passive's
Install Puppet.
Edit the puppet.conf and set the server variable in the `agent` section to be
the active Puppet master, e.g. `server = active.puppetlabs.vm`.
Remove the `server` entry from the `main` section.
Ensure dns_alt_names are included.
Remove SSL directory on completion.
Run Puppet on the passive master and sign the certificate on the active master

### Beginning with puppet_master_manager

Classify active and passive masters with `puppet_master_manager`:

```puppet
    class { 'puppet_master_manager':
      active_master   => 'active.puppetlabs.vm',
      passive_master  => 'passive.puppetlabs.vm',
      rsync_user      => 'root',
    }
```

## Usage

## Reference

### Classes
* `puppet_master_manager`: base class to determine if active or passive master
* `puppet_master_manager::active`: class to manage active master
* `puppet_master_manager::passive`: class to manage passive master

### Parameters

#### `puppet_master_manager`

#####`active_server`
 FQDN of the active Puppet Master.
 Required.

#####`dump_path`
 Directory to dump PSQL dumps to if Active Master.
 Only for Active Puppet Master.
 Defaults to `/opt/dump`.

#####`hour`
 Value for the hour(s) to dump Postgresql.
 Only for Active Puppet Master.
 Defaults to `23`.

#####`minute`
 Value for the minute(s) to dump Postgresql.
 Only for Active Puppet Master.
 Defaults to `30`.

#####`monthday`
 Value for the day of month to dump Postgresql
 Only for Active Puppet Master.
 Defaults to `*`.

#####`dumpall_monthday`
 Value for the day of month to dumpall Postgresql
 Only for Active Puppet Master.
 Defaults to `1`.

#####`passive_master`
 Hostname (FQDN) of Passive Master.

#####`script_dir`
Directory to store certificate transfer script.
Defaults to `/root/scripts`.

#####`rsync_user`
User for rsync job to Secondary (Passive) Master.
Defaults to `root`.

## Limitations

RHEL 6

## Development

Submit PRs if you want

