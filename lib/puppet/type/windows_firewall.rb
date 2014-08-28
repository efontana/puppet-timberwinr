Puppet::Type.newtype(:windows_firewall) do
	ensurable

	newparam(:name, :nameval => true) do
		desc "Name for this batch of port openings"
	end

	newparam(:ports) do
		desc "The ports to open. Ports will be opened to all incoming connections."
	end

	newproperty(:wtf) do
		desc "wtf"
	end
end
