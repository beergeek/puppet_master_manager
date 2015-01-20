# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
class { 'puppet_master_manager':
  active_master              => 'm0.puppetlabs.vm',
  enable_replication         => true,
  passive_master             => 'm1.puppetlabs.vm',
  replication_address        => '192.168.62.0/24',
  replication_user           => 'replicator',
  replication_user_hash      => 'd8d8295af2a24691580159a4540d8a6b',
}
