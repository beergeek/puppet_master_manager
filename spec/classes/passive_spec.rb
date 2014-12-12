require 'spec_helper'
describe 'puppet_master_manager::passive' do
  let(:facts) {
    {
      :fqdn => 'passive.puppetlabs.vm',
    }
  }

  context 'correct parameters' do

    it { should contain_class('puppet_master_manager::passive')}

    it {
      should contain_package('rsync').with(
        'ensure'  => 'present',
      )
    }

    it {
      should contain_file('/etc/puppetlabs/puppet/ssl/certs/pe-internal-dashboard.pem').with(
        'ensure'  => 'file',
        'owner'   => 'pe-puppet',
        'group'   => 'pe-puppet',
        'mode'    => '0644',
      )
    }

    it {
      should contain_file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-dashboard.pem').with(
        'ensure'  => 'file',
        'owner'   => 'pe-puppet',
        'group'   => 'pe-puppet',
        'mode'    => '0644',
      )
    }

    it {
      should contain_file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-dashboard.pem').with(
        'ensure'  => 'file',
        'owner'   => 'pe-puppet',
        'group'   => 'pe-puppet',
        'mode'    => '0400',
      )
    }

    it {
      should contain_file('/etc/puppetlabs/puppet/ssl/certs/pe-internal-classifier.pem').with(
        'ensure'  => 'file',
        'owner'   => 'pe-puppet',
        'group'   => 'pe-puppet',
        'mode'    => '0644',
      )
    }

    it {
      should contain_file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-classifier.pem').with(
        'ensure'  => 'file',
        'owner'   => 'pe-puppet',
        'group'   => 'pe-puppet',
        'mode'    => '0644',
      )
    }

    it {
      should contain_file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-classifier.pem').with(
        'ensure'  => 'file',
        'owner'   => 'pe-puppet',
        'group'   => 'pe-puppet',
        'mode'    => '0400',
      )
    }

    it {
      should contain_file('postgres_private_key').with(
        'ensure'  => 'file',
        'path'    => '/opt/puppet/var/lib/pgsql/9.2/data/certs/passive.puppetlabs.vm.private_key.pem',
        'owner'   => 'pe-postgres',
        'group'   => 'pe-postgres',
        'mode'    => '0600',
        'source'  => '/etc/puppetlabs/puppet/ssl/private_keys/passive.puppetlabs.vm.pem',
      )
    }

    it {
      should contain_file('postgres_public_key').with(
        'ensure'  => 'file',
        'path'    => '/opt/puppet/var/lib/pgsql/9.2/data/certs/passive.puppetlabs.vm.public_key.pem',
        'owner'   => 'pe-postgres',
        'group'   => 'pe-postgres',
        'mode'    => '0600',
        'source'  => '/etc/puppetlabs/puppet/ssl/public_keys/passive.puppetlabs.vm.pem',
      )
    }

    it {
      should contain_file('postgres_cert').with(
        'ensure'  => 'file',
        'path'    => '/opt/puppet/var/lib/pgsql/9.2/data/certs/passive.puppetlabs.vm.cert.pem',
        'owner'   => 'pe-postgres',
        'group'   => 'pe-postgres',
        'mode'    => '0600',
        'source'  => '/etc/puppetlabs/puppet/ssl/certs/passive.puppetlabs.vm.pem',
      )
    }

  end
end
