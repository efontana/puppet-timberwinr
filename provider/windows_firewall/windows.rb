require 'puppet'
require 'puppet/error'

# Knows how to manage ports in a Windows firewall
Puppet::Type.type(:windows_firewall).provide(:windows) do
	desc "Windows firewall management"

	confine :operatingsystem => :windows
	defaultfor :operatingsystem => :windows

	def create
		name = resource[:name]

		# Create each port rule. No need to check if they exist yet.
		resource[:ports].each do |p|
			`netsh advfirewall firewall add rule name="#{name}" dir=in action=allow protocol=TCP localport=#{p}`
			self.info "Opening port #{p}"
		end

	end

	def destroy
		# Destroys all the rules associated with this name.
		name = resource[:name]
		resource[:ports].each do |p|
			self.info "Deleting rule for port #{p}"
			`netsh advfirewall firewall delete rule name="#{name}" protocol=TCP localport=#{p}`
		end
	end

	def exists?
		self.info "Querying for existing rules"
		current_rules = `netsh advfirewall firewall show rule name=all`

		resource[:ports].each do |p|
			# If we find any rules that aren't configured correctly, bail out.
			if !(current_rules =~ /LocalPort:\s+#{p}/)
				self.info "Coulnd't find a rule for port #{p}"
				return false
			end
		end

		self.info "All rules matched"
		return true
	end
end