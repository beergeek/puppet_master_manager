# == Class: puppet_master_manager
#
#
# === Parameters
#
# [*active_server*]
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
class puppet_master_manager (
  $active_server,
  $dump_path        = $puppet_master_manager::params::dump_path,
  $dumpall_monthday = $puppet_master_manager::params::dumpall_monthday,
  $hour             = $puppet_master_manager::params::hour,
  $minute           = $puppet_master_manager::params::minute,
  $monthday         = $puppet_master_manager::params::monthday,
  $passive_master   = undef,
  $rsync_user       = $puppet_master_manager::params::rsync_user,
) inherits puppet_master_manager::params {

  if $active_server == $::fqdn {

    class { 'puppet_master_manager::active':
      dump_path        => $dump_path,
      dumpall_monthday => $dumpall_monthday,
      hour             => $hour,
      minute           => $minute,
      monthday         => $monthday,
      passive_master   => $passive_master,
      rsync_user       => $rsync_user,
    }

  } else {
    class { 'puppet_master_manager::passive':
    }
  }


}
