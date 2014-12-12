class puppet_master_manager::passive {

  File {
    owner => 'pe-puppet',
    group => 'pe-puppet',
    mode  => '0644',
  }

  ensure_packages('rsync')

  file { '/etc/puppetlabs/puppet/ssl/certs/pe-internal-dashboard.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/certs/pe-internal-dashboard.pem'),
  }

  file { '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-dashboard.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-dashboard.pem'),
  }

  file { '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-dashboard.pem':
    ensure  => file,
    mode    => '0400',
    content => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-dashboard.pem'),
  }

  file { '/etc/puppetlabs/puppet/ssl/certs/pe-internal-classifier.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/certs/pe-internal-classifier.pem'),
  }

  file { '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-classifier.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-classifier.pem'),
  }

  file { '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-classifier.pem':
    ensure  => file,
    mode    => '0400',
    content => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-classifier.pem'),
  }

  file { 'postgres_private_key':
    ensure => file,
    path   => "/opt/puppet/var/lib/pgsql/9.2/data/certs/${::fqdn}.private_key.pem",
    owner  => 'pe-postgres',
    group  => 'pe-postgres',
    mode   => '0600',
    source => "/etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem",
  }

  file { 'postgres_public_key':
    ensure => file,
    path   => "/opt/puppet/var/lib/pgsql/9.2/data/certs/${::fqdn}.public_key.pem",
    owner  => 'pe-postgres',
    group  => 'pe-postgres',
    mode   => '0600',
    source => "/etc/puppetlabs/puppet/ssl/public_keys/${::fqdn}.pem",
  }

  file { 'postgres_cert':
    ensure => file,
    path   => "/opt/puppet/var/lib/pgsql/9.2/data/certs/${::fqdn}.cert.pem",
    owner  => 'pe-postgres',
    group  => 'pe-postgres',
    mode   => '0600',
    source => "/etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem",
  }
}
