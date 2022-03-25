require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)
load "util.rb"

###

template = File.foreach("../template/servers.csv")
ca = File.read("../static/ca.crt")
tls_wrap = read_tls_wrap("auth", 1, "../static/ta.key", 1)

cfg = {
  ca: ca,
  tlsWrap: tls_wrap,
  cipher: "AES-256-CBC",
  digest: "SHA512",
  compressionFraming: 1,
  keepAliveSeconds: 15,
  renegotiatesAfterSeconds: 0,
  checksEKU: true,
  randomizeEndpoint: true
}

basic = {
  id: "default",
  name: "Default",
  comment: "256-bit encryption",
  ovpn: {
    cfg: cfg,
    endpoints: [
      "UDP:1194",
      "TCP:443"
    ]
  }
}
double = {
  id: "double",
  name: "Double VPN",
  comment: "256-bit encryption",
  ovpn: {
    cfg: cfg,
    endpoints: [
      "TCP:443"
    ]
  }
}
presets = [basic, double]

defaults = {
  :username => "user@mail.com",
  :country => "US"
}

###

servers = []
template.with_index { |line, n|
  id, country, secondary, num, hostname = line.strip.split(",")

  server = {
    :id => id,
    :country => country.upcase
  }
  server[:presets] = ["default"]
  if !secondary.empty?
    if secondary == "onion"
      server[:tags] = [secondary]
    else
      server[:category] = "double"
      server[:presets] = ["double"]
      server[:extra_countries] = [secondary.upcase]
    end
  end
  server[:num] = num.to_i
  server[:hostname] = hostname
  servers << server
}

###

infra = {
  :servers => servers,
  :presets => presets,
  :defaults => defaults
}

puts infra.to_json
puts
