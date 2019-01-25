#!/usr/bin/lua
local core = require("docker-core")

local function main()
  core.update_user()
  core.run("su-exec core /usr/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.conf")
end

main()
