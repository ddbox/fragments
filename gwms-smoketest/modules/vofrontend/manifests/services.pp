class vofrontend::services{


  service{'condor':
    ensure     => true,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }


  service{'gwms-frontend':
    ensure     => stopped,
    enable     => false,
    hasstatus  => true,
    hasrestart => true,
    notify => Exec['upgrade-frontend'],
  }

  $release_major = $facts['os']['release']['major']
  case $release_major{
     '6': {
       $start_frontend_command = '/sbin/service gwms-frontend upgrade'
     }
     'default': {
       $start_frontend_command = 'gwms-frontend upgrade'
     }
   }

  exec{'upgrade-frontend':
     command => "$start_frontend_command",
     notify => Exec['start-frontend'],
   }

   exec { 'start-frontend':
     command => '/sbin/service gwms-frontend start',
   }

  service{'httpd':
    ensure     => true,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}

