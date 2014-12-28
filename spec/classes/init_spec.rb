require 'spec_helper'
describe 'puppet_master_manager' do
  let(:params) {
    {
      :active_master   => 'active.puppetlabs.vm',
      :passive_master => 'passive.puppetlabs.vm',
    }
  }

  context 'declared for Active master' do
    let(:facts) {
      {
        :fqdn  => 'active.puppetlabs.vm',
      }
    }

    it { should contain_class('puppet_master_manager') }
    it { should contain_class('puppet_master_manager::active') }

  end

  context 'declared for Passive master' do
    let(:facts) {
      {
        :fqdn  => 'passive.puppetlabs.vm',
      }
    }

    it { should contain_class('puppet_master_manager') }
    it { should contain_class('puppet_master_manager::passive') }

  end
end
