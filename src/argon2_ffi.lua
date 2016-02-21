local ffi = require "ffi"
local ffi_str = ffi.string
local ffi_new = ffi.new
local fmt = string.format
local find = string.find
local getinfo = debug.getinfo

local ENCODED_LEN = 108
local HASH_LEN = 32
local OPTIONS = {
  t_cost = 2,
  m_cost = 12,
  parallelism = 1,
  argon2d = false
}

ffi.cdef [[
typedef enum Argon2_type { Argon2_d = 0, Argon2_i = 1 } argon2_type;

int argon2_hash(const uint32_t t_cost, const uint32_t m_cost,
                const uint32_t parallelism, const void *pwd,
                const size_t pwdlen, const void *salt, const size_t saltlen,
                void *hash, const size_t hashlen, char *encoded,
                const size_t encodedlen, argon2_type type);

int argon2_verify(const char *encoded, const void *pwd, const size_t pwdlen,
                  argon2_type type);

const char *error_message(int error_code);
]]

local argon2_t = ffi.typeof(ffi_new "argon2_type")
local buf = ffi_new("char[?]", ENCODED_LEN)

local lib = ffi.load "argon2"

local function check_arg(arg, arg_n, exp_type)
  if type(arg) ~= exp_type then
    local info = getinfo(2)
    local err = fmt("bad argument #%d to '%s' (%s expected, got %s)",
                    arg_n, info.name, exp_type, type(arg))
    error(err, 3)
  end
end

local _M = {}

function _M.encrypt(pwd, salt, opts)
  check_arg(pwd, 1, "string")
  check_arg(salt, 2, "string")
  if opts ~= nil then
    check_arg(opts, 3, "table")
  else
    opts = {}
  end

  for k, v in pairs(OPTIONS) do
    if opts[k] == nil then
      opts[k] = v
    elseif k ~= "argon2d" and type(opts[k]) ~= "number" then
      error("expected "..k.." to be a number", 2)
    end
  end

  local p = ffi_new("char[?]", #pwd+1, pwd)
  local s = ffi_new("char[?]", #salt+1, salt)
  local t = ffi_new(argon2_t, opts.argon2d and "Argon2_d" or "Argon2_i")

  local ret = lib.argon2_hash(opts.t_cost, opts.m_cost, opts.parallelism,
                              p, #pwd, s, #salt,
                              nil, HASH_LEN, buf, ENCODED_LEN, t)

  if ret == 0 then
    return ffi_str(buf)
  else
    local msg = lib.error_message(ret)
    return nil, ffi_str(msg)
  end
end

function _M.verify(hash, plain)
  local h = ffi_new("char[?]", #hash+1, hash)
  local p = ffi_new("char[?]", #plain+1, plain)
  local argon2d = find(hash, "argon2d") ~= nil
  local t = ffi_new(argon2_t, argon2d and "Argon2_d" or "Argon2_i")

  local ret = lib.argon2_verify(h, p, #plain, t)
  if ret == 0 then
    return true
  else
    return false, "The password did not match."
  end
end

return _M
