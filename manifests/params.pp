class puppet_master_manager::params {

  $archive_mode       = 'on'
  $archive_command    = 'cp %p /opt/puppet/var/lib/pgsql/9.2/backups/%f'
  $archive_timeout    = '120'
  $dump_path          = '/opt/dump'
  $dumpall_monthday   = '1'
  $hour               = '23'
  $minute             = '30'
  $monthday           = '*'
  $rsync_user         = 'root'
  $script_dir         = '/root/scripts'
  $wal_level          = 'hot_standby'
  $max_wal_senders    = '5'
  $wal_keep_segments  = '200'
  $replication_user   = 'replicator'
  $replication_method = 'md5'

}
