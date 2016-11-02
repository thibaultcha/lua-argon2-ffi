-- vim:set st=4 sw=4 et:
local ffi = require "ffi"


local ffi_str = ffi.string
local find    = string.find
local error   = error
local pairs   = pairs
local type    = type


ffi.cdef [[
    typedef enum Argon2_type { Argon2_d = 0, Argon2_i = 1 } argon2_type;

    int argon2i_hash_encoded(const uint32_t t_cost,
                            const uint32_t m_cost,
                            const uint32_t parallelism,
                            const void *pwd, const size_t pwdlen,
                            const void *salt, const size_t saltlen,
                            const size_t hashlen, char *encoded,
                            const size_t encodedlen);

    int argon2d_hash_encoded(const uint32_t t_cost,
                            const uint32_t m_cost,
                            const uint32_t parallelism,
                            const void *pwd, const size_t pwdlen,
                            const void *salt, const size_t saltlen,
                            const size_t hashlen, char *encoded,
                            const size_t encodedlen);

    int argon2_verify(const char *encoded,
                    const void *pwd,
                    const size_t pwdlen,
                    argon2_type type);

    const char *argon2_error_message(int error_code);
]]


local ENCODED_LEN = 108
local HASH_LEN    = 32
local OPTIONS     = {
    t_cost        = 2,
    m_cost        = 12,
    parallelism   = 1,
    argon2d       = false,
}


local buf = ffi.new("char[?]", ENCODED_LEN)
local argon2_t = ffi.typeof(ffi.new "argon2_type")
local c_type_i = ffi.new(argon2_t, "Argon2_i")
local c_type_d = ffi.new(argon2_t, "Argon2_d")


local lib = ffi.load "argon2"


local _M     = {
    _VERSION = "1.0.0",
    _AUTHOR  = "Thibault Charbonnier",
    _LICENSE = "MIT",
    _URL     = "https://github.com/thibaultCha/lua-argon2-ffi",
}


function _M.encrypt(pwd, salt, opts)
    if type(pwd) ~= "string" then
        return error("bad argument #1 to 'encrypt' (string expected, got " .. type(pwd) .. ")", 2)

    elseif type(salt) ~= "string" then
        return error("bad argument #2 to 'encrypt' (string expected, got " .. type(salt) .. ")", 2)
    end

    if opts == nil then
        opts = OPTIONS

    elseif type(opts) ~= "table" then
        return error("bad argument #3 to 'encrypt' (table expected, got " .. type(opts) .. ")", 2)

    else
        for k, v in pairs(OPTIONS) do
            local o = opts[k]

            if o == nil then
                opts[k] = v

            elseif k ~= "argon2d" and type(o) ~= "number" then
                return error("expected " .. k .. " to be a number", 2)
            end
        end
    end

    local res
    if opts.argon2d then
        res = lib.argon2d_hash_encoded(opts.t_cost, opts.m_cost, opts.parallelism,
        pwd, #pwd, salt, #salt, HASH_LEN, buf, ENCODED_LEN)
    else
        res = lib.argon2i_hash_encoded(opts.t_cost, opts.m_cost, opts.parallelism,
        pwd, #pwd, salt, #salt, HASH_LEN, buf, ENCODED_LEN)
    end

    if res ~= 0 then
        local c_msg = lib.argon2_error_message(res)
        return nil, ffi_str(c_msg)
    end

    return ffi_str(buf)
end


function _M.verify(hash, plain)
    if type(hash) ~= "string" then
        return error("bad argument #1 to 'verify' (string expected, got " .. type(hash) .. ")", 2)

    elseif type(plain) ~= "string" then
        return error("bad argument #2 to 'verify' (string expected, got " .. type(plain) .. ")", 2)
    end

    local argon2d = find(hash, "argon2d", nil, true) ~= nil
    local c_type = argon2d and c_type_d or c_type_i

    local res = lib.argon2_verify(hash, plain, #plain, c_type)

    if res ~= 0 then
        return false, "The password did not match."
    end

    return true
end


return _M
