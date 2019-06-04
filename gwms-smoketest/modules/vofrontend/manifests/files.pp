class vofrontend::files{
  
  user {'frontend':
    ensure=> present,
  }

  file { '/etc/condor/certs/condor_mapfile':
    ensure  => file,
    owner   => 'root',
    mode    => '0644',
    content => template('vofrontend/etc.condor.certs.condor_mapfile.erb'),
  }

  file { '/etc/gwms-frontend/frontend.xml':
    ensure  => file,
    owner   => 'frontend',
    mode    => '0644',
    content => template('vofrontend/frontend.xml.erb'),
  }
  file { '/tmp/vo_proxy':
    ensure  => file,
    owner   => 'frontend',
    mode    => '0600',
  }

  file { '/tmp/frontend_proxy':
    ensure  => file,
    owner   => 'frontend',
    mode    => '0600',
  }

}


