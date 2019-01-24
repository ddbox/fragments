class vofrontend::files{
  

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



}


