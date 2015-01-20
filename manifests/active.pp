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
  $archive_mode               = $puppet_master_manager::params::archive_mode,
  $archive_command            = $puppet_master_manager::params::archive_command,
  $archive_timeout            = $puppet_master_manager::params::archive_timeout,
  $dump_path                  = $puppet_master_manager::params::dump_path,
  $dumpall_monthday           = $puppet_master_manager::params::dumpall_monthday,
  $enable_replication         = false,
  $hour                       = $puppet_master_manager::params::hour,
  $max_wal_senders            = $puppet_master_manager::params::max_wal_senders,
  $minute                     = $puppet_master_manager::params::minute,
  $monthday                   = $puppet_master_manager::params::monthday,
  $passive_master             = undef,
  $replication_address        = undef,
  $replication_method         = $puppet_master_manager::params::replication_method,
  $replication_user           = $puppet_master_manager::params::replication_user,
  $replication_user_hash      = undef,
  $rsync_user                 = $puppet_master_manager::params::rsync_user,
  $script_dir                 = $puppet_master_manager::params::script_dir,
  $wal_keep_segments          = $puppet_master_manager::params::wal_keep_segments,
  $wal_level                  = $puppet_master_manager::params::wal_level,
) inherits puppet_master_manager::params  {

  # using 'member' function as will most likely add more modes to this array
  if ! member(['hot_standby'],$wal_level) {
    fail("${wal_level} is not a valid wal_level")
  }
  if ! member(['on','off'],$archive_mode) {
    fail("${wal_level} is not a valid archive_mode")
  }
  validate_bool($enable_replication)

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

    if $enable_replication {

      class { '::pe_postgresql::globals':
        user                 => 'pe-postgres',
        group                => 'pe-postgres',
        client_package_name  => 'pe-postgresql',
        server_package_name  => 'pe-postgresql-server',
        contrib_package_name => 'pe-postgresql-contrib',
        service_name         => 'pe-postgresql',
        default_database     => 'pe-postgres',
        version              => '9.2',
        bindir               => '/opt/puppet/bin',
        datadir              => "/opt/puppet/var/lib/pgsql/9.2/data",
        confdir              => "/opt/puppet/var/lib/pgsql/9.2/data",
        psql_path            => '/opt/puppet/bin/psql',
        needs_initdb         => false,
      }

      include pe_postgresql::server::contrib

      class { '::pe_postgresql::server':
        listen_addresses        => '*',
        ip_mask_allow_all_users => '0.0.0.0/0',
      }

      pe_postgresql::server::config_entry { 'archive_mode':
        ensure => present,
        value  => $archive_mode,
      }

      pe_postgresql::server::config_entry { 'archive_command':
        ensure => present,
        value  => $archive_command,
      }

      pe_postgresql::server::config_entry { 'archive_timeout':
        ensure => present,
        value  => $archive_timeout,
      }

      pe_postgresql::server::config_entry { 'wal_level':
        ensure => present,
        value  => $wal_level,
      }

      pe_postgresql::server::config_entry { 'max_wal_senders':
        ensure => present,
        value  => $max_wal_senders,
      }

      pe_postgresql::server::config_entry { 'wal_keep_segments':
        ensure => present,
        value  => $wal_keep_segments,
      }

      pe_postgresql::server::role { 'replication_user':
        name          => $replication_user,
        replication   => true,
        password_hash => $replication_user_hash,
      }

      pe_postgresql::server::pg_hba_rule { 'replication_user':
        address     => $replication_address,
        auth_method => $replication_method,
        database    => 'replication',
        description => 'replication user',
        type        => 'host',
        user        => $replication_user,
      }

    }

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
    command  => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c console -f ${dump_path}/console_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
  }

  cron { 'puppet_activity_dumps':
    ensure   => present,
    command  => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-activity -f ${dump_path}/activity_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
  }

  cron { 'puppet_classifier_dumps':
    ensure   => present,
    command  => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-classifier -f ${dump_path}/classifier_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
  }

  cron { 'puppet_rbac_dumps':
    ensure   => present,
    command  => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-rbac -f ${dump_path}/rbac_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
  }

  cron { 'puppet_puppetdb_dumps':
    ensure   => present,
    command  => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-puppetdb -f ${dump_path}/puppetdb_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
  }

  cron { 'puppet_dumpall':
    ensure   => present,
    command  => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dumpall -f ${dump_path}/dumpall_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
    monthday => $dumpall_monthday,
  }

}
