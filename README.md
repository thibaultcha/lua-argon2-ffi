# lua-argon2-ffi
[![Module Version][badge-version-image]][luarocks-argon2-ffi]
[![Build Status][badge-travis-image]][badge-travis-url]
[![Coverage Status][badge-coveralls-image]][badge-coveralls-url]

FFI binding of [Argon2] for LuaJIT.

While [lua-argon2] provides a pure Lua binding through the Lua C API, this
module is for use with LuaJIT only, especially in [ngx_lua]/[OpenResty], though
the performance gains are very limited due to the nature of Argon2.

### Prerequisites

The [Argon2] shared library must be compiled and available in your system.

Compatibility:
- Version `0.x` of this module is compatible with Argon2
  [`20151206`](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20151206)

### Install

This binding can be installed via [Luarocks](https://luarocks.org):

```
$ luarocks install argon2-ffi
```

Or simply by copying the `src/argon2.lua` file in your `LUA_PATH`.

### Usage

**Note**: lua-argon2-ffi uses the same API as [lua-argon2], to the exception of
the default settings capabilities of lua-argon2.

Encrypt:

```lua
local argon2 = require "argon2"
--- Prototype
-- local hash, err = argon2.encrypt(pwd, salt, opts)

--- Argon2i
local hash = assert(argon2.encrypt("password", "somesalt"))
-- hash: "$argon2i$m=12,t=2,p=1$c29tZXNhbHQ$ltrjNRFqTXmsHj++TFGZxg+zSg8hSrrSJiViCRns1HM"

--- Argon2d
local hash = assert(argon2.encrypt("password", "somesalt", {argon2d = true}))
-- hash: "$argon2d$m=12,t=2,p=1$c29tZXNhbHQ$mfklun4fYCbv2Hw0UnZZ56xAqWbjD+XRMSN9h6SfLe4"

-- Hashing options
local hash = assert(argon2.encrypt("password", "somesalt", {
  t_cost = 4,
  m_cost = 24,
  parallelism = 2
}))
-- hash: "$argon2i$m=24,t=4,p=2$c29tZXNhbHQ$8BtAMKSLKR3l66c3l40LKrg09NwLD7hJYfSqoLQyKEE"
```

Verify:

```lua
local argon2 = require "argon2"
--- Prototype
-- local ok, err = argon2.decrypt(hash, plain)

local hash = assert(argon2.encrypt("password", "somesalt"))
-- hash: argon2i hash

assert(argon2.verify(hash, "password")) -- ok: true
assert(argon2.verify(hash, "passworld")) -- error: The password did not match
```

### Documentation

Since the API is the same as [lua-argon2]'s, the documentation is available at
<http://thibaultcha.github.io/lua-argon2>.

### License

Work licensed under the MIT License. Please check
[P-H-C/phc-winner-argon2][Argon2] for license over Argon2 and the reference
implementation.

[Argon2]: https://github.com/P-H-C/phc-winner-argon2
[lua-argon2]: https://github.com/thibaultCha/lua-argon2
[luarocks-argon2-ffi]: http://luarocks.org/modules/thibaultcha/argon2-ffi

[ngx_lua]: https://github.com/openresty/lua-nginx-module
[OpenResty]: https://openresty.org

[badge-travis-url]: https://travis-ci.org/thibaultCha/lua-argon2-ffi
[badge-travis-image]: https://travis-ci.org/thibaultCha/lua-argon2-ffi.svg?branch=master
[badge-version-image]: https://img.shields.io/badge/version-0.0.1-blue.svg?style=flat
[badge-coveralls-url]: https://coveralls.io/github/thibaultCha/lua-argon2-ffi?branch=master
[badge-coveralls-image]: https://coveralls.io/repos/github/thibaultCha/lua-argon2-ffi/badge.svg?branch=master
