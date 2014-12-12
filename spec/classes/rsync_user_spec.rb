require 'spec_helper'
describe 'puppet_master_manager::rsync_user' do

  context 'correct parameters' do

    it {
      should contain_file('/homoe/root/.ssh/ssh_config').with(
        'ensure'  => 'file',
      )
    }
  end
end
