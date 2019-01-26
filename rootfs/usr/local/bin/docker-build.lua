#!/usr/bin/lua
local core = require("docker-core")

local function prepare(tmp)
  core.run(
    "apk add --no-cache --virtual .build-dependencies build-base cmake linux-headers zlib-dev mbedtls-dev cyrus-sasl-dev fts-dev"
  )
  core.run("mkdir -p %s", tmp)
  core.run("wget -qO %s.tgz https://fluentbit.io/releases/1.0/fluent-bit-1.0.3.tar.gz", tmp)
  core.run("tar --extract --gzip --file %s.tgz --strip-components=1 --directory %s", tmp, tmp)
  core.append_file(tmp .. "/lib/chunkio/include/chunkio/chunkio.h", "#include <sys/types.h> \n")
end

local function arguments()
  local flags = {
    FLB_TLS = "Yes",
    FLB_SHARED_LIB = "No",
    FLB_EXAMPLES = "No",
    FLB_HTTP_SERVER = "Yes",
    FLB_SQLDB = "Yes",
    FLB_CORO_STACK_SIZE = "100000",
    -- FLB_IN_HTTP = "Yes",
    -- FLB_OUT_RETRY = "Yes",
    FLB_OUT_KAFKA = "Yes",
    CMAKE_INSTALL_PREFIX = "/usr",
    CMAKE_INSTALL_SYSCONFDIR = "/etc",
    ["CMAKE_INSTALL_LIBDIR:PATH"] = "lib"
  }

  local index = 1
  local items = {}

  for name, item in pairs(flags) do
    items[index] = string.format("-D%s=%s", name, item)
    index = index + 1
  end

  return table.concat(items, " ")
end

local function make(tmp)
  core.run("cd %s", tmp .. "/build")
  core.run("cmake %s ..", arguments())
  core.run("make install")
  core.run("make clean")
  core.run("cd /")
end

local function clean(tmp)
  core.run("rm -rf /usr/include %s", tmp)
  core.run("rm -f %s.tgz", tmp)
  core.run("apk del .build-dependencies")
end

local function update()
  local etc = "/etc/fluent-bit"
  local conf = "fluent-bit.conf"
  core.run("mv %s/%s %s/default.%s", etc, conf, etc, conf)
  core.run("mv %s/.%s %s/%s", etc, conf, etc, conf)
end

local function main()
  local tmp = "/tmp/fluent-bit"
  -- core.run("apk add --no-cache lua-rex-pcre")
  core.run("apk add --no-cache libgcc libsasl")
  core.run("mkdir -p /var/log/fluent-bit /usr/local/etc/fluent-bit")
  prepare(tmp)
  make(tmp)
  clean(tmp)
  update()
end

main()
