# Repo installation
class wazuh::repo (
  $redhat_manage_epel = true,
) {

  case $::osfamily {
    'Debian' : {
      # apt-key added by issue #34
      apt::key { 'puppetlabs':
        id     => '9FE55537D1713CA519DFB85114B9C8DB9A1B1C65',
        source => 'http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key'
      }
      case $::lsbdistcodename {
        /(precise|trusty|vivid|wily|xenial|yakketi)/: {

          apt::source { 'wazuh':
            ensure   => present,
            comment  => 'This is the WAZUH Ubuntu repository for Ossec',
            location => 'http://ossec.wazuh.com/repos/apt/ubuntu',
            release  => $::lsbdistcodename,
            repos    => 'main',
            include  => {
              'src' => false,
              'deb' => true,
            },
          }
          ~>
          exec { 'update-apt-wazuh-repo':
            command     => '/usr/bin/apt-get update',
            refreshonly => true
          }

        }
        /^(jessie|wheezy|stretch|sid)$/: {
          apt::source { 'wazuh':
            ensure   => present,
            comment  => 'This is the WAZUH Debian repository for Ossec',
            location => 'http://ossec.wazuh.com/repos/apt/debian',
            release  => $::lsbdistcodename,
            repos    => 'main',
            include  => {
              'src' => false,
              'deb' => true,
            },
          }
          ~>
          exec { 'update-apt-wazuh-repo':
            command     => '/usr/bin/apt-get update',
            refreshonly => true
          }
        }
        default: { fail('This ossec module has not been tested on your distribution (or lsb package not installed)') }
      }
    }
    'Linux', 'Redhat' : {
      if ( $::operatingsystem == 'Amazon' ) {
        $repotype = 'Amazon Linux'
        $baseurl  = 'https://packages.wazuh.com/yum/rhel/6Server/$basearch'
        $gpgkey   = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
      } elsif ( $::os[name] == 'CentOS' ) {
        if ( $::operatingsystemrelease =~ /^5.*/ ) {
          $repotype = 'CentOS 5'
          $baseurl  = 'https://packages.wazuh.com/yum/el/$releasever/$basearch'
          $gpgkey   = 'https://packages.wazuh.com/key/RPM-GPG-KEY-OSSEC-RHEL5'
        } else {
          $repotype = 'CentOS > 5'
          $baseurl  = 'https://packages.wazuh.com/yum/el/$releasever/$basearch'
          $gpgkey   = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
        } elsif ( $::os[name] == 'Redhat' ) {
          if ( $::operatingsystemrelease =~ /^5.*/ ) {
            $repotype = 'CentOS 5'
            $baseurl  = 'https://packages.wazuh.com/yum/rhel/$releasever/$basearch'
            $gpgkey   = 'https://packages.wazuh.com/key/RPM-GPG-KEY-OSSEC-RHEL5'
          } else {
            $repotype = 'CentOS > 5'
            $baseurl  = 'https://packages.wazuh.com/yum/rhel/$releasever/$basearch'
            $gpgkey   = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
            }
          }
        } elsif ( $::os[name] == 'Fedora' ) {
            $repotype = 'Fedora'
            $baseurl  = 'https://packages.wazuh.com/yum/fc/$releasever/$basearch'
            $gpgkey   = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
          }
      }
      # Set up OSSEC repo
      yumrepo { 'wazuh':
        descr    => "WAZUH OSSEC Repository - www.wazuh.com # ${repotype}",
        enabled  => true,
        gpgcheck => 1,
        gpgkey   => $gpgkey,
        baseurl  => $baseurl
      }

      if $redhat_manage_epel {
        # Set up EPEL repo
        # NOTE: This relies on the 'epel' module referenced in metadata.json
        package { 'inotify-tools':
          ensure  => present
        }
        include epel

        Class['epel'] -> Package['inotify-tools']
      }
    }
    default: { fail('This ossec module has not been tested on your distribution') }
  }
}