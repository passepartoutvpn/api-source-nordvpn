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
ca = File.read("../template/ca.crt")
tls_wrap = read_tls_wrap("auth", 1, "../template/ta.key", 1, 18)

cfg = {
    ca: ca,
    wrap: tls_wrap,
    ep: [
        "UDP:1194",
        "TCP:443"
    ],
    cipher: "AES-256-CBC",
    auth: "SHA512",
    frame: 1,
    ping: 15,
    reneg: 0,
    eku: true,
    random: true
}

recommended = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: cfg
}
presets = [recommended]

defaults = {
    :username => "user@mail.com",
    :pool => "us",
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
