# == Class: puppet_master_manager::active
#
#
# === Parameters
#
# [*dump_path*]
#   Directory to dump PSQL dumps to if Active Master.
#   Only for Active Puppet Master.
#   Defaults to `/opt/dump`.
#
# [*hour*]
#   Value for the hour(s) to dump Postgresql.
#   Only for Active Puppet Master.
#   Defaults to `23`.
#
# [*minute*]
#   Value for the minute(s) to dump Postgresql.
#   Only for Active Puppet Master.
#   Defaults to `30`.
#
# [*monthday*]
#   Value for the day of month to dump Postgresql
#   Only for Active Puppet Master.
#   Defaults to `*`.
#
# [*dumpall_monthday*]
#   Value for the day of month to dumpall Postgresql
#   Only for Active Puppet Master.
#   Defaults to `1`.
#
# [*passive_master*]
#   Hostname (FQDN) of Passive Master.
#
# [*rsync_user*]
#   User for rsync job to Secondary (Passive) Master.
#   Required if `secondary_master` is present.
#
# === Authors
#
# Brett Gray <brett.gray@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs, unless otherwise noted.
#
class puppet_master_manager::active (
  $dump_path        = $puppet_master_manager::params::dump_path,
  $dumpall_monthday = $puppet_master_manager::params::dumpall_monthday,
  $hour             = $puppet_master_manager::params::hour,
  $minute           = $puppet_master_manager::params::minute,
  $monthday         = $puppet_master_manager::params::monthday,
  $passive_master   = undef,
  $script_dir       = $puppet_master_manager::params::script_dir,
  $rsync_user       = $puppet_master_manager::params::rsync_user,
) inherits puppet_master_manager::params  {

  $rsync_ssl_dir        = '/etc/puppetlabs/puppet/ssl/ca/'
  $incron_ssl_condition = "${::settings::ssldir}/ca/signed IN_CREATE,IN_DELETE,IN_MODIFY"
  $rsync_command        = "rsync -apu /etc/puppetlabs/puppet/ssl/ca/*"
  $incron_command       = "${rsync_command} ${rsync_user}@${passive_master}:${rsync_ssl_dir}\n"

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  Cron {
    user     => 'root',
    hour     => $hour,
    minute   => $minute,
    monthday => $monthday,
    require  => File['dump_directory'],
  }

  if $passive_master {
    ensure_packages(['rsync','incron'])

    file { 'script_dir':
      ensure => directory,
      path   => $script_dir,
    }

    file { 'sync_script':
      ensure  => file,
      path    => "${script_dir}/sync_script",
      mode    => '0750',
      content => $incron_command,
    }

    file { '/etc/incron.d/sync_certs':
      ensure  => file,
      mode    => '0744',
      content => "${incron_ssl_condition} ${script_dir}/sync_script",
      notify  => Service['incrond'],
      require => Package['incron'],
    }

    service { 'incrond':
      ensure    => running,
      enable    => true,
      subscribe => File['/etc/incron.d/sync_certs'],
    }
  }

  file { 'dump_directory':
    ensure => directory,
    path   => $dump_path,
    owner  => 'pe-postgres',
    mode   => '0700',
  }

  cron { 'puppet_console_dumps':
    ensure   => present,
    command  => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 console' > ${dump_path}/console_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
  }

  cron { 'puppet_activity_dumps':
    ensure   => present,
    command  => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-activity' > ${dump_path}/activity_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
  }

  cron { 'puppet_classifier_dumps':
    ensure   => present,
    command  => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-classifier' > ${dump_path}/classifier_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
  }

  cron { 'puppet_rbac_dumps':
    ensure   => present,
    command  => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-rbac' > ${dump_path}/rbac_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
  }

  cron { 'puppet_puppetdb_dumps':
    ensure   => present,
    command  => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-puppetdb' > ${dump_path}/puppetdb_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
  }

  cron { 'puppet_dumpall':
    ensure   => present,
    command  => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dumpall' > ${dump_path}/dumpall_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
    monthday => $dumpall_monthday,
  }

}
