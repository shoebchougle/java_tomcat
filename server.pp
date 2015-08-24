node 'webserver.home.local' {
		
	package { 	"wget":
				ensure => "installed",
			}

	exec	{	'extract_java':
				command => '/bin/tar -zxf /root/packages/jdk-8u60-linux-i586.tar.gz -C /opt/',
				creates => '/opt/jdk1.8.0_60',
			}

	exec	{	'install_java':
				command => '/usr/sbin/alternatives --install /usr/bin/java java /opt/jdk1.8.0_60/bin/java 2 && /usr/sbin/alternatives --auto java && /usr/sbin/update-alternatives --set java /opt/jdk1.8.0_60/bin/java',
				creates => '/usr/bin/java',
				require => Exec['extract_java'],
			}

	file	{	'/usr/bin/java':
				ensure => 'link',
				target => '/opt/jdk1.8.0_60/bin/java',
				require => Exec['install_java'],
			}

	exec	{	'extract_tomcat':
				command => '/bin/tar -zxf /root/packages/apache-tomcat-8.0.24.tar.gz -C /opt/',
				creates => '/opt/apache-tomcat-8.0.24',
			}

	file	{	'/usr/local/tomcat8':
				ensure => 'link',
				target => '/opt/apache-tomcat-8.0.24',
			}

	firewall{ 	'0100-INPUT ACCEPT 8080':
				port  => 8080,
				proto  => 'tcp',
				action => 'accept',
			}

	# tomcat init script
	file 	{ 	'/etc/init.d/tomcat':
				ensure  => 'present',
				content => template('tomcat/etc/init.d/tomcat.erb'),
				mode => '+x',
				require => file['/usr/local/tomcat8'],
	}

	service { 	'tomcat':
				ensure => 'running',
				enable => 'true',
				hasstatus  => 'true',
				hasrestart => 'true',
				status => '/usr/sbin/service tomcat status | grep "is running"',
				require => File['/etc/init.d/tomcat'],
			}
}
