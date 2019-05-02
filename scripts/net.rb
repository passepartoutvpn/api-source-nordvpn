require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

def read_tls_wrap(strategy, dir, file, from, to)
    lines = File.foreach(file)
    key = ""
    lines.with_index { |line, n|
        next if n < from or n >= to
        key << line.strip
    }
    key64 = [[key].pack("H*")].pack("m0")

    return {
        strategy: strategy,
        key: {
            dir: dir,
            data: key64
        }
    }
end

###

servers = File.foreach("../template/servers.csv")
ca = File.read("../static/ca.crt")
tls_wrap = read_tls_wrap("auth", 1, "../static/ta.key", 1, 17)

cfg = {
    ca: ca,
    wrap: tls_wrap,
    cipher: "AES-256-CBC",
    auth: "SHA512",
    frame: 1,
    ping: 15,
    reneg: 0,
    eku: true,
    random: true
}

external = {
    hostname: "${id}.nordvpn.com"
}

basic_cfg = cfg.dup
basic_cfg["ep"] = ["UDP:1194", "TCP:443"]

double_cfg = cfg.dup
double_cfg["ep"] = ["TCP:443"]

basic = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: basic_cfg,
    external: external
}
double = {
    id: "double",
    name: "Double VPN",
    comment: "256-bit encryption",
    cfg: double_cfg,
    external: external
}
presets = [basic, double]

defaults = {
    :username => "user@mail.com",
    :pool => "us",
    :preset => "default"
}

###

pools = []
servers.with_index { |line, n|
    id, country, secondary, num, hostname = line.strip.split(",")

    pool = {
        :id => id,
        :country => country.upcase
    }
    pool[:presets] = ["default"]
    if !secondary.empty?
        if secondary == "onion"
            pool[:tags] = [secondary]
        else
            pool[:category] = "double"
            pool[:presets] = ["double"]
            pool[:extra_countries] = [secondary.upcase]
        end
    end
    pool[:num] = num.to_i
    pool[:hostname] = hostname
    pools << pool
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
