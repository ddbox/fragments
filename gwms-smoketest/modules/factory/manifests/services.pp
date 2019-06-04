class factory::services{


  service{'condor':
    ensure     => true,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }


  service{'gwms-factory':
    ensure     => stopped,
    enable     => false,
    hasstatus  => true,
    hasrestart => true,
    notify => Exec['upgrade-factory'],
  }

  $release_major = $facts['os']['release']['major']
  case $release_major{
     '6': {
       $start_factory_command = '/sbin/service gwms-factory upgrade'
     }
     'default': {
       $start_factory_command = 'gwms-factory upgrade'
     }
   }

  exec{'upgrade-factory':
     command => "$start_factory_command",
     notify => Exec['start-factory'],
   }

   exec { 'start-factory':
     command => '/sbin/service gwms-factory start',
   }

  service{'httpd':
    ensure     => true,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}

