require 'spec_helper'
describe 'puppet_master_manager::active' do

  context 'all defaults' do

    it {
      should_not contain_package('rsync')
    }

    it {
      should_not contain_package('incron')
    }

    it {
      should_not contain_file('/etc/incron.d/sync_certs')
    }

    it {
      should_not contain_service('incrond')
    }

    it {
      should contain_file('dump_directory').with(
        'ensure'  => 'directory',
        'path'    => '/opt/dump',
        'owner'   => 'pe-postgres',
        'group'   => 'root',
        'mode'    => '0700',
      )
    }

    it {
      should contain_cron('puppet_console_dumps').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c console -f /opt/dump/console_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '*',
        'require'   => 'File[dump_directory]'
      )
    }

    it {
      should contain_cron('puppet_activity_dumps').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-activity -f /opt/dump/activity_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '*',
        'require'   => 'File[dump_directory]'
      )
    }

    it {
      should contain_cron('puppet_classifier_dumps').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-classifier -f /opt/dump/classifier_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '*',
        'require'   => 'File[dump_directory]'
      )
    }

    it {
      should contain_cron('puppet_rbac_dumps').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-rbac -f /opt/dump/rbac_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '*',
        'require'   => 'File[dump_directory]'
      )
    }

    it {
      should contain_cron('puppet_puppetdb_dumps').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-puppetdb -f /opt/dump/puppetdb_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '*',
        'require'   => 'File[dump_directory]'
      )
    }

    it {
      should contain_cron('puppet_dumpall').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dumpall -f /opt/dump/dumpall_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '1',
        'require'   => 'File[dump_directory]'
      )
    }
  end

  context 'correct parameters' do
    let(:params) {
      {
        :passive_master => 'passive.puppetlabs.vm',
      }
    }

    it {
      should contain_package('rsync').with(
        'ensure'  => 'present',
      )
    }

    it {
      should contain_package('incron').with(
        'ensure'  => 'present',
      )
    }

    it {
      should contain_file('script_dir').with(
        'ensure'  => 'directory',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      )
    }

    it {
      should contain_file('/etc/incron.d/sync_certs').with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0744',
        'require' => 'Package[incron]',
      ).with_content(/\/puppet\/ssl\/ca\/signed/)
      .with_content(/IN_CREATE\,IN_DELETE\,IN_MODIFY /)
    }

    it {
      should contain_file('sync_script').with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0750',
      ).with_content(/rsync -apu \/etc\/puppetlabs\/puppet\/ssl\/ca\/\* /)
      .with_content(/root@passive\.puppetlabs\.vm:\/etc\/puppetlabs\/puppet\/ssl\/ca\/\n/)
    }

    it {
      should contain_service('incrond').with(
        'ensure'  => 'running',
        'enable'  => true,
      )
    }

    it {
      should contain_file('dump_directory').with(
        'ensure'  => 'directory',
        'path'    => '/opt/dump',
        'owner'   => 'pe-postgres',
        'group'   => 'root',
        'mode'    => '0700',
      )
    }

    it {
      should contain_cron('puppet_console_dumps').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c console -f /opt/dump/console_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '*',
        'require'   => 'File[dump_directory]'
      )
    }

    it {
      should contain_cron('puppet_activity_dumps').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-activity -f /opt/dump/activity_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '*',
        'require'   => 'File[dump_directory]'
      )
    }

    it {
      should contain_cron('puppet_classifier_dumps').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-classifier -f /opt/dump/classifier_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '*',
        'require'   => 'File[dump_directory]'
      )
    }

    it {
      should contain_cron('puppet_rbac_dumps').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-rbac -f /opt/dump/rbac_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '*',
        'require'   => 'File[dump_directory]'
      )
    }

    it {
      should contain_cron('puppet_puppetdb_dumps').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dump -Fc -C -c pe-puppetdb -f /opt/dump/puppetdb_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '*',
        'require'   => 'File[dump_directory]'
      )
    }

    it {
      should contain_cron('puppet_dumpall').with(
        'ensure'    => 'present',
        'command'   => "/usr/bin/sudo -u pe-postgres /opt/puppet/bin/pg_dumpall -f /opt/dump/dumpall_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '1',
        'require'   => 'File[dump_directory]'
      )
    }
  end

  context "with replication enabled" do
    let(:params) {
      {
        :enable_replication         => true,
        :passive_master             => 'passive.puppetlabs.vm',
        :replication_address        => '192.168.0.0/28',
        :replication_user           => 'replicator',
        :replication_user_hash      => 'd8d8295af2a24691580159a4540d8a6b',
      }
    }
    let(:facts) {
      {
        :pe_concat_basedir => '/tmp',
      }
    }

    it {
      should contain_pe_postgresql__server__config_entry('archive_mode').with(
        "ensure"  => "present",
        "value"   => "on",
      )
    }

    it {
      should contain_pe_postgresql__server__config_entry('archive_command').with(
        "ensure"  => "present",
        "value"   => "cp %p /opt/puppet/var/lib/pgsql/9.2/backups/%f",
      )
    }

    it {
      should contain_pe_postgresql__server__config_entry('archive_timeout').with(
        "ensure"  => "present",
        "value"   => "120",
      )
    }

    it {
      should contain_pe_postgresql__server__config_entry('wal_level').with(
        "ensure"  => "present",
        "value"   => "hot_standby",
      )
    }

    it {
      should contain_pe_postgresql__server__config_entry('max_wal_senders').with(
        "ensure"  => "present",
        "value"   => "5",
      )
    }

    it {
      should contain_pe_postgresql__server__config_entry('wal_keep_segments').with(
        "ensure"  => "present",
        "value"   => "200",
      )
    }

    it {
      should contain_pe_postgresql__server__role('replication_user').with(
        "replication"     => true,
        "password_hash"   => "d8d8295af2a24691580159a4540d8a6b",
      )
    }

    it {
      should contain_pe_postgresql__server__pg_hba_rule('replication_user').with(
        'description' => 'replication user',
        'type'        => 'host',
        'database'    => 'replication',
        'user'        => 'replicator',
        'address'     => '192.168.0.0/28',
        'auth_method' => 'md5',
      )
    }

  end


  context "Incorrect values" do
    let(:params) {
      {
        :wal_level           => "sleeping",
        :enable_replication  => "maybe",
        :passive_master      => 'passive.puppetlabs.vm',
      }
    }

    it {
      expect { subject }.to raise_error(Puppet::Error, /is not a valid/)
    }
  end
end
