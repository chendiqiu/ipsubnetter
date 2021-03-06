require_relative 'ipaddress'
require_relative 'iputils'
require 'json'

class IPSubnet

    include IP_utils;

    def init_ips
        @startingIP = IPAddress.new;
        @endingIP = IPAddress.new;
    end

    def initialize(*args)
        init_ips;
        @startingIP.set args[0];
        @endingIP.set args[1];
        @req = args[2];
    end

    def to_s
        {
            startingIP: @startingIP.to_s,
            endingIP: @endingIP.to_s,
            broadcastIP: broadcastAddress.to_s,
            mask: maskAddress.to_s
        }
    end

    def broadcastAddress
        @endingIP - 1;
    end

    def maskAddress
        IPAddress.new getNHostSubnetMask @req;
    end

    def to_json
        to_s.to_json
    end
end

class IPSubnetter
    def init_ips
        @base_ip = IPAddress.new;
        @default_mask = IPAddress.new;
    end
    def initialize(*args)
        init_ips;
        @base_ip.set args[0];
        @default_mask.set args[1];
    end

    """
    given a list of required numbers of hosts for each subnet,
    perform a subnetting task
    """
    def doSubnet(reqs)
        reqs = reqs.sort.reverse
        reqs.inject(Array.new){|list, x|
            startingIP = @base_ip + 1;
            endingIP = @base_ip + (2**(Math.log2(x + 1)).ceil - 2)
            list.push(IPSubnet.new(startingIP, endingIP, x));
            @base_ip = list[-1].broadcastAddress + 1;
            list;
        }
    end
end

base = IPAddress.new("172.29.0.0");
defaultMask = IPAddress.new("255.255.252.0");
reqs = [260,177,50,20,2,2,2];
IPSubnetter.new(base, defaultMask).doSubnet(reqs).each {|x|
    p x.to_json
}

#p IPSubnet.new(174, 38).to_json


























### whitespace guard
