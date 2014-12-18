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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 console' > /opt/dump/console_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-activity' > /opt/dump/activity_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-classifier' > /opt/dump/classifier_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-rbac' > /opt/dump/rbac_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-puppetdb' > /opt/dump/puppetdb_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dumpall' > /opt/dump/dumpall_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 console' > /opt/dump/console_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-activity' > /opt/dump/activity_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-classifier' > /opt/dump/classifier_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-rbac' > /opt/dump/rbac_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dump -Fc -C -c -p 5432 pe-puppetdb' > /opt/dump/puppetdb_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
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
        'command'   => "/bin/su - pe-postgres -s /bin/bash -c '/opt/puppet/bin/pg_dumpall' > /opt/dump/dumpall_`/bin/date +'\\%Y\\%m\\%d\\%H\\%M'`",
        'user'      => 'root',
        'hour'      => '23',
        'minute'    => '30',
        'monthday'  => '1',
        'require'   => 'File[dump_directory]'
      )
    }
  end
end
