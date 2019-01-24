class vofrontend::services{



  service{'condor':
    ensure     => true,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }


  service{'gwms-frontend':
    ensure     => true,
    enable     => false,
    hasstatus  => true,
    hasrestart => true,
  }

  service{'httpd':
    ensure     => true,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}

