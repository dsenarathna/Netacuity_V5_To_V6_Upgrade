# Class: netacuity
#
# This class manages the netacuity database
#
# Parameters:
#
# Actions:
#   - Manage netacuity database
#
# Requires:
#
# Sample Usage:
#

class netacuity inherits netacuity::params {

  case $::osfamily {
	'RedHat': {

      # netacuity version lookup
      $netacuity_version = hiera('netacuity_version', '5.1.0.9')

      # netacuity v5 stuff
      if ($netacuity_version == '5.1.0.9') {
        # requires java 7
        $java_version = hiera('package_java_jdk')
        # required files
        file {
          ['/opt/NetAcuity','/opt/NetAcuity/server']:
            ensure     => directory,
            owner      => 'root',
            group      => 'netacuity',
            mode       => '0664';
          ['/opt/NetAcuity/server/netacuity.cfg']:
            owner      => 'root',
            group      => 'netacuity',
            mode       => '0644',
            content    => template("${::puppet_dir_master}/systems/_LINUX_/opt/NetAcuity/server/netacuity.cfg");
          ['/etc/init.d/NetAcuity']:
            owner     =>  'root',
            group     =>  'root',
            mode      =>  '0755',
            content   =>  template("${::puppet_dir_master}/systems/_LINUX_/etc/init.d/NetAcuity");
          }
      service {
        'NetAcuity':
          ensure     => running,
          enable     => true,
          hasrestart => true,
          hasstatus  => true,
          require    => [Package["NetAcuity-${netacuity_version}"], File['/etc/init.d/NetAcuity']];
      }
}
      # netacuity v6 stuff
	  # cannot do enable = true for service because its not supported
	  # service NetAcuity does not support chkconfig
	  
       elsif ($netacuity_version == '6.3.5.1')  {
	  
        # set java_version to java8
        $java_version = hiera('package_java8_jdk')
		
        # include java8 install class
        include java::jdk8

        # required files
        file {
          ['/etc/init.d/NetAcuity']:
            owner     =>  'root',
            group     =>  'root',
            mode      =>  '0755',
            content   =>  template("${::puppet_dir_master}/systems/_LINUX_/etc/init.d/NetAcuity-${netacuity_version}");

            }
		}
         package {
           "NetAcuity-${netacuity_version}":
             ensure  => installed,
             require => [Package["${java_version}"]];
                 }

      }
    default: {
      notify {"Not Redhat based OS, skipping all the things...":}
    }
  }
}

