require 'spec_helper'
describe 'puppet_master_manager::rsync_user' do

  context 'correct parameters' do
    let(:params) {
      {
        :rsync_user   => 'rsync_user',
        :rsync_group  => 'rsync_user',
        :manage_user  => true,
        :ssh_key      => '',
        :home_dir     => '/home/rsync_user'
      }
    }

    it {
      should contain_user('rsync_user').with(
        'ensure'  => 'present',
        'name'    => 'rsync_user',
        'gid'     => 'rsync_user',
        'home'    => '/home/rsync_user',
      )
    }

    it {
      should contain_file('home_dir').with(
        'ensure'  => 'directory',
        'path'    => '/home/rsync_user',
        'owner'   => 'rsync_user',
        'group'   => 'rsync_user',
        'mode'    => '0700',
      )
    }

    it {
      should contain_file('ssh_dir').with(
        'ensure'  => 'directory',
        'path'    => '/home/rsync_user/.ssh',
        'owner'   => 'rsync_user',
        'group'   => 'rsync_user',
        'mode'    => '0700',
      )
    }

    it {
      should contain_augeas('ssh_config').with(
        'context' => '/files/home/rsync_user/.ssh/config',
        'changes' => 'set IdentityFile /home/rsync_user/.ssh/id_rsa',
      )
    }
  end
end
