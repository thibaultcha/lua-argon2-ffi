package = "argon2-ffi"
version = "0.0.1-0"
source = {
  url = "git://github.com/thibaultCha/lua-argon2-ffi",
  tag = "0.0.1"
}
description = {
  summary = "LuaJIT FFI binding for the Argon2 password hashing algorithm",
  homepage = "https://github.com/thibaultCha/lua-argon2-ffi",
  license = "MIT"
}
build = {
  type = "builtin",
  modules = {
    ["argon2"] = "src/argon2.lua"
  }
}
