require 'spec_helper'
describe 'puppet_master_manager' do

  context 'declared for Active master' do
    let(:params) {
      {
        :active_master  => 'active.puppetlabs.vm',
        :passive_master => 'passive.puppetlabs.vm',
      }
    }
    let(:facts) {
      {
        :fqdn  => 'active.puppetlabs.vm',
      }
    }

    it { should contain_class('puppet_master_manager') }
    it { should contain_class('puppet_master_manager::active') }

  end

  context 'declared for Passive master' do
    let(:params) {
      {
        :active_master  => 'active.puppetlabs.vm',
        :passive_master => 'passive.puppetlabs.vm',
      }
    }
    let(:facts) {
      {
        :fqdn  => 'passive.puppetlabs.vm',
      }
    }

    it { should contain_class('puppet_master_manager') }
    it { should contain_class('puppet_master_manager::passive') }

  end

  context 'declared for Active master, with replication' do
    let(:params) {
      {
        :active_master              => 'active.puppetlabs.vm',
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
        :fqdn               => 'active.puppetlabs.vm',
      }
    }

    it { should contain_class('puppet_master_manager') }
    it { should contain_class('puppet_master_manager::active') }

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
      )
    }
  end

end
