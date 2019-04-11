require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

servers = File.foreach("../template/servers.csv")

cfg = {
    ep: [
        "UDP:1194",
        "TCP:443"
    ],
    cipher: "AES-256-CBC",
    auth: "SHA512",
    frame: 1,
    wrap: {
        strategy: "auth",
        key: {
            dir: 1,
            data: "" # dummy data to pass JSON validator
        }
    },
    ping: 15,
    reneg: 0,
    eku: true,
    random: true
}

recommended = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: cfg,
    external: {
        "ca": "${id}_nordvpn_com_ca.crt",
        "wrap.key.data": "${id}_nordvpn_com_tls.key"
    }
}
presets = [recommended]

defaults = {
    :username => "user@mail.com",
    :pool => "us1309",
    :preset => "default"
}

###

pools = []
servers.with_index { |line, n|
    id, country, area, num, hostname = line.strip.split(",")

    pool = {
        :id => id,
        :name => "",
        :country => country.upcase
    }
    pool[:area] = area if !area.empty?
    pool[:num] = num
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
