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
				line=self.sanitize(line)
				Puppet.debug("Info-line="+line.inspect)
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
				line=self.sanitize(line)
				Puppet.debug("Search-line="+line.inspect)
				if line.match(/^\[[ ]*(installed|uninstalled|upgrade)[ ]*\] \- #{$package}\-.*/) 
					Puppet.debug("Found a match! status="+$1)
					$status = $1
				end
			}
		end
		
		if "#{$ens}"=="present"
			#install or upgrade package if needed
			Puppet.debug("package should be installed, status="+$status)
			if $status=="upgrade" 
				execpipe("/usr/sbin/slackpkg -batch=on -default_answer=y upgrade " + $package) do |process|
					process.each{ |line|
						Puppet.debug(line)
					}
				end
				Puppet.debug("${package} upgraded")
			end
			if $status=="uninstalled" 
				execpipe("/usr/sbin/slackpkg -batch=on -default_answer=y install " + $name) do |process|
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
				$data=self.query
				$rname="#{$data[:name]}-#{$data[:desired]}"
				execpipe("/usr/sbin/slackpkg -batch=on -default_answer=y remove " + $rname) do |process|
					process.each{ |line|
						Puppet.debug(line)
					}
				end
				Puppet.debug("#{$rname} removed")
			end
		end
	
	
    	end
	
	def update
		self.install
	end
	
	def latest
		self.install
	end
	
	def sanitize (data)
		result= data.gsub(/\e\[\?[0-9]*[lh]/, '')
		if result==nil
			return data
		else
			return result
		end
	end

	def query
		Puppet.debug("query")
		hash = {
				:ensure => :purged,
				:status => 'missing',
				:name => @resource[:name],
				:error => 'ok',
		}
		
		execpipe("/usr/sbin/slackpkg search #{@resource[:name]}") do |process|
			Puppet.debug("testing for status of package: #{@resource[:name]}")
			process.each{ |line|
				line=self.sanitize(line)
				Puppet.debug(line.inspect)
				if line.match(/^\[[ ]*(installed|uninstalled|upgrade)[ ]*\] \- #{@resource[:name]}\-.*/)
					Puppet.debug("Found! status=#{$1}")
					$status=$1
					if $status=='installed' or $status=='upgrade'
						$hstatus='installed'
						$hensure=:present
					end
					if $status=='uninstalled'
						$hstatus='missing'
						$hensure=:absent
					end
				end
			}

		end
		execpipe("cat /var/lib/slackpkg/pkglist") do |process|
			process.each{ |line|
				line=self.sanitize(line)
				#Puppet.debug('Looking for package in pkglist')
				if line.match(/^[a-zA-Z0-9]* #{@resource[:name]} ([0-9\.]*) .*/)
					hash = {
							:ensure => $hensure,
							:desired => $1,
							:status => $hstatus,
							:name => @resource[:name],
							:error => 'ok',
					}
					Puppet.debug("Package #{$hstatus}")
				end
			}
		end

		return hash
	end


	def uninstall
		self.install
	end
end
