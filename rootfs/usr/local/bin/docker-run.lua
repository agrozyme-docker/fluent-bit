#!/usr/bin/lua
local core = require("docker-core")

local function main()
  core.update_user()
  core.chown("/var/log/fluent-bit")
  core.run("/usr/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.conf")
end

main()
