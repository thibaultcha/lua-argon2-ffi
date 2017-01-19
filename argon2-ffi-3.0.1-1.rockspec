package = "argon2-ffi"
version = "3.0.1-1"
source = {
  url = "git://github.com/thibaultcha/lua-argon2-ffi",
  tag = "3.0.1"
}
description = {
  summary = "LuaJIT FFI binding for the Argon2 password hashing function",
  homepage = "https://github.com/thibaultcha/lua-argon2-ffi",
  license = "MIT"
}
build = {
  type = "builtin",
  modules = {
    ["argon2"] = "src/argon2.lua"
  }
}
