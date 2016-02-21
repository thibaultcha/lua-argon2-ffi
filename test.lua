local argon2 = require "src.argon2_ffi"
local hash, err = argon2.encrypt("password", "somesalt")
print(hash)
local hash, err = argon2.encrypt2("password", "somesalt")
print(hash)
