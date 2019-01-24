# == Class:factory 
#
# Full description of class factory here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class factory($condor_tarball_version='8.6.5', $fact_fqdn='FIXME', $vofe_fqdn='FIXME')  {
    class { 'factory::vars' : }
    class { 'factory::packages' : }
    class { 'factory::files' : }
    class { 'factory::services' : }


}

