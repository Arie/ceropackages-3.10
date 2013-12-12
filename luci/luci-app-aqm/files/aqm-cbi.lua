--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local wa = require "luci.tools.webadmin"
local fs = require "nixio.fs"
local net = require "luci.model.network".init()
local ifaces = net:get_interfaces()
local path = "/usr/lib/aqm"

m = Map("aqm", translate("Active Queue Management"),
	translate("With <abbr title=\"Active Queue Management\">AQM</abbr> you " ..
		"can enable traffic shaping and prioritisation on one or more " ..
		"network interfaces."))

s = m:section(TypedSection, "queue", translate("Queues"))
s.addremove = true
s.anonymous = true

n = s:option(ListValue, "interface", translate("Interface name"))
for _, iface in ipairs(ifaces) do
     if iface:is_up() then
	n:value(iface:name())
     end
end
n.rmempty = false

e = s:option(Flag, "enabled", translate("Enable"))
e.rmempty = false

dl = s:option(Value, "download", translate("Download speed (kbit/s)"))
dl.datatype = "and(uinteger,min(1))"
dl.rmempty = false

ul = s:option(Value, "upload", translate("Upload speed (kbit/s)"))
ul.datatype = "and(uinteger,min(1))"
ul.rmempty = false

c = s:option(ListValue, "qdisc", translate("Queueing discipline"))
c:value("fq_codel", "fq_codel ("..translate("default")..")")
c:value("efq_codel")
c:value("nfq_codel")
c:value("sfq")
c:value("codel")
c:value("ns2_codel")
c:value("pie")
c:value("sfq")
c.default = "fq_codel"
c.rmempty = false

local qos_desc = ""
sc = s:option(ListValue, "script", translate("Queue setup script"))
for file in fs.dir(path) do
  if string.find(file, ".qos$") then
    sc:value(file)
  end
  if string.find(file, ".qos.help$") then
    fh = io.open(path .. "/" .. file, "r")
    qos_desc = qos_desc .. "<p><b>" .. file:gsub(".help$", "") .. ":</b><br />" .. fh:read("*a") .. "</p>"
  end
end
sc.default = "simple.qos"
sc.rmempty = false
sc.description = qos_desc

dl = s:option(Value, "download", translate("Download speed (kbit/s)"))
dl.datatype = "and(uinteger,min(1))"
dl.rmempty = false

ul = s:option(Value, "upload", translate("Upload speed (kbit/s)"))
ul.datatype = "and(uinteger,min(1))"
ul.rmempty = false

lla = s:option(ListValue, "linklayer_adaptation_mechanism", translate("Which linklayer adaptation mechanism to use")) -- Creates an element list (select box)
lla:value("none")
lla:value("htb_private")
lla:value("tc_stab")
lla.default = "none"

ll = s:option(ListValue, "linklayer", translate("Which linklayer to account for")) -- Creates an element list (select box)
ll:value("ethernet")
ll:value("adsl")
ll:value("atm")
ll.default = "ethernet"

po = s:option(Value, "overhead", translate("Per Packet Overhead (byte)"))
po.datatype = "and(integer,min(-1500))"
po.default = 0
po.isnumber = true
po.rmempty = false

smtu = s:option(Value, "MTU", translate("Maximal Size for size and rate calculations (byte), needs to be >= interface MTU"))
smtu.datatype = "and(uinteger,min(0))"
smtu.default = 2047
smtu.isnumber = true
smtu.rmempty = false

stsize = s:option(Value, "TSIZE", translate("Number of entries in size/rate tables, for ATM choose TSIZE = (MTU + 1) / 16"))
stsize.datatype = "and(uinteger,min(0))"
stsize.default = 128
stsize.isnumber = true
stsize.rmempty = false

smpu = s:option(Value, "MPU", translate("Minimal packet size (byte), if needs to be >0 for ethernet size tables"))
smpu.datatype = "and(uinteger,min(0))"
smpu.default = 0
smpu.isnumber = true
smpu.rmempty = false


return m
