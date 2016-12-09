-- vim:set st=4 sw=4 et:
local ffi = require "ffi"


local ffi_new = ffi.new
local ffi_str = ffi.string
local find    = string.find
local error   = error
local pairs   = pairs
local type    = type


ffi.cdef [[
    typedef enum Argon2_type {
        Argon2_d  = 0,
        Argon2_i  = 1,
        Argon2_id = 2
    } argon2_type;

    const char *argon2_error_message(int error_code);

    size_t argon2_encodedlen(uint32_t t_cost, uint32_t m_cost,
                             uint32_t parallelism, uint32_t saltlen,
                             uint32_t hashlen, argon2_type type);

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

    int argon2id_hash_encoded(const uint32_t t_cost,
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
]]


local lib = ffi.load "argon2"


local ARGON2_OK              = 0
local ARGON2_VERIFY_MISMATCH = -35


local argon2_i, argon2_d, argon2_id


do
    local argon2_t = ffi.typeof(ffi.new "argon2_type")

    argon2_i = ffi_new(argon2_t, "Argon2_i")
    argon2_d = ffi_new(argon2_t, "Argon2_d")
    argon2_id = ffi_new(argon2_t, "Argon2_id")
end


local OPTIONS   = {
    t_cost      = 3,
    m_cost      = 4096,
    parallelism = 1,
    hash_len    = 32,
    variant     = argon2_i,
}


local _M     = {
    _VERSION = "3.0.0",
    _AUTHOR  = "Thibault Charbonnier",
    _LICENSE = "MIT",
    _URL     = "https://github.com/thibaultcha/lua-argon2-ffi",
    variants = {
        argon2_i = argon2_i,
        argon2_d = argon2_d,
        argon2_id = argon2_id,
    },
}


function _M.hash_encoded(pwd, salt, opts)
    if type(pwd) ~= "string" then
        return error("bad argument #1 to 'hash_encoded' (string expected, got "
                     .. type(pwd) .. ")", 2)
    end

    if type(salt) ~= "string" then
        return error("bad argument #2 to 'hash_encoded' (string expected, got "
                     .. type(salt) .. ")", 2)
    end

    if opts and type(opts) ~= "table" then
        return error("bad argument #3 to 'hash_encoded' (expected to be a "
                     .. "table)", 2)
    end

    if opts == nil then
        opts = OPTIONS

    else
        for k, v in pairs(OPTIONS) do
            local o = opts[k]

            if o == nil then
                opts[k] = v

            elseif k == "variant" then
                if type(o) ~= "cdata" then
                    return error("bad argument #3 to 'hash_encoded' (expected "
                                 .. k .. " to be an argon2_type, got "
                                 .. type(o) .. ")", 2)
                end

            elseif type(o) ~= "number" then
                return error("bad argument #3 to 'hash_encoded' (expected "
                             .. k .. " to be a number, got "
                             .. type(o) .. ")", 2)
            end
        end
    end

    local buf_len = lib.argon2_encodedlen(opts.t_cost, opts.m_cost,
                                          opts.parallelism, #salt,
                                          opts.hash_len, opts.variant)

    local buf = ffi_new("char[?]", buf_len)
    local ret_code

    if opts.variant == argon2_d then
        ret_code = lib.argon2d_hash_encoded(opts.t_cost, opts.m_cost,
                                            opts.parallelism, pwd, #pwd, salt,
                                            #salt, opts.hash_len, buf, buf_len)

    elseif opts.variant == argon2_id then
        ret_code = lib.argon2id_hash_encoded(opts.t_cost, opts.m_cost,
                                             opts.parallelism, pwd, #pwd, salt,
                                             #salt, opts.hash_len, buf, buf_len)

    else
        ret_code = lib.argon2i_hash_encoded(opts.t_cost, opts.m_cost,
                                            opts.parallelism, pwd, #pwd, salt,
                                            #salt, opts.hash_len, buf, buf_len)
    end

    if ret_code ~= ARGON2_OK then
        local c_msg = lib.argon2_error_message(ret_code)
        return nil, ffi_str(c_msg)
    end

    return ffi_str(buf)
end


function _M.verify(encoded, plain)
    if type(encoded) ~= "string" then
        return error("bad argument #1 to 'verify' (string expected, got "
                     .. type(encoded) .. ")", 2)
    end

    if type(plain) ~= "string" then
        return error("bad argument #2 to 'verify' (string expected, got "
                     .. type(plain) .. ")", 2)
    end

    local variant

    if find(encoded, "argon2d", nil, true) then
        variant = argon2_d

    elseif find(encoded, "argon2id", nil, true) then
        variant = argon2_id

    else
        variant = argon2_i
    end

    local ret_code = lib.argon2_verify(encoded, plain, #plain, variant)

    if ret_code == ARGON2_VERIFY_MISMATCH then
        return false
    end

    if ret_code ~= ARGON2_OK then
        local c_msg = lib.argon2_error_message(ret_code)
        return nil, ffi_str(c_msg)
    end

    return true
end


return _M
