# == Class: puppet_master_manager
#
#
# === Parameters
#
# [*active_master*]
#   FQDN of the active Puppet Master.
#   Required.
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
# [*script_dir*]
#   Directory to store certificate transfer script.
#   Defaults to `/root/scripts`.
#
# [*rsync_user*]
#   User for rsync job to Secondary (Passive) Master.
#   Defaults to `root`.
#
# === Authors
#
# Brett Gray <brett.gray@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs, unless otherwise noted.
#
class puppet_master_manager (
  $active_master,
  $archive_mode               = $puppet_master_manager::params::archive_mode,
  $archive_command            = $puppet_master_manager::params::archive_command,
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
) inherits puppet_master_manager::params {

  if $active_master == $::fqdn {

    class { 'puppet_master_manager::active':
      archive_mode          => $archive_mode,
      archive_command       => $archive_command,
      dump_path             => $dump_path,
      dumpall_monthday      => $dumpall_monthday,
      enable_replication    => $enable_replication,
      hour                  => $hour,
      max_wal_senders       => $max_wal_senders,
      minute                => $minute,
      monthday              => $monthday,
      passive_master        => $passive_master,
      rsync_user            => $rsync_user,
      replication_address   => $replication_address,
      replication_method    => $replication_method,
      replication_user      => $replication_user,
      replication_user_hash => $replication_user_hash,
      wal_keep_segments     => $wal_keep_segments,
      wal_level             => $wal_level,
    }

  } else {
    class { 'puppet_master_manager::passive':
    }
  }


}
