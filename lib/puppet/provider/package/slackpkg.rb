require 'puppet/provider/package'

Puppet::Type.type(:package).provide :slackpkg, :parent => Puppet::Provider::Package do
	desc "Package management via slackpkg."

	defaultfor :operatintsystem => [:slackware, :bluewhite64, :slamd64, :slackware64]
	confine :operatingsystem => [:slackware, :bluewhite64, :slamd64, :slackware64]
	
	commands :slackpkg => "/usr/sbin/slackpkg"
	
	def self.instances
		Puppet.debug("instances():startup")
		return {}
	end
	
	def self.collect #apparently this is needed
		
	end
	Puppet.debug("Slackpkg called")

	def install
		$package = @resource[:name].to_s
		$ens = @resource[:ensure].to_s
		Puppet.debug("Got called with variables package=" + $package + " and ensure= #{$ens}")

		#check exact package name
		execpipe("/usr/sbin/slackpkg info " + $package) do |process|
			$name = nil
			process.each { |line|
				Puppet.debug("Info-line="+line)
				if line.match(/^PACKAGE NAME\:[ ]*([a-zA-Z0-9\-\_\.]*)\.t[xg]z$/) 
					Puppet.debug("found a match! name = "+$1)
					$name = $1
				end
			}
		end
		#check status
		execpipe("/usr/sbin/slackpkg search " + $package) do |process|
			$status = nil
			process.each { |line|
				Puppet.debug("Search-line="+line)
				if line.match(/^\[[ ]*(installed|uninstalled|upgrade)[ ]*\] \- #{$package}\-.*/) 
					Puppet.debug("Found a match! status="+$1)
					$status = $1
				end
			}
		end
		
		if $ens=='present'
			#install or upgrade package if needed
			Puppet.debug("package should be installed, status="+$status)
			if $status=="upgrade" 
				execpipe("/usr/sbin/slackpkg upgrade " + $package) do |process|
					process.each{ |line|
						Puppet.debug(line)
					}
				end
				Puppet.debug("${package} upgraded")
			end
			if $status=="uninstalled" 
				execpipe("/usr/sbin/slackpkg install " + $name) do |process|
					process.each{ |line|
						Puppet.debug(line)
					}
				end
				Puppet.debug("#{$package} installed")
			end
		else
			Puppet.debug("package should be removed, status="+$status)
			#remove package if need be
			if $status!="uninstalled"
				execpipe("/usr/sbin/slackpkg remove " + $name) do |process|
					process.each{ |line|
						Puppet.debug(line)
					}
				end
				Puppet.debug("${package} removed")
			end
		end
	
	
    	end
	
	def update
		self.install
	end
	
	def latest
		self.install
	end

	def query
		Puppet.debug("query")
		hash = {
				:ensure => :purged,
				:status => 'missing',
				:name => @resource[:name],
				:error => 'ok',
		}
		return hash #self.install already queries, it's not neat but I'm lazy.
	end


	def uninstall
		self.install
	end
end
