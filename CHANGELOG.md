## [Unreleased][unrelease]

## [3.0.1] - 2017/01/18

### Added

- Ensure `hash_encoded()` and `verify()` are JIT compiled in LuaJIT 2.1.
  [#11](https://github.com/thibaultcha/lua-argon2-ffi/pull/11)

## [3.0.0] - 2016/12/08

**Note**: This module's version was bumped to `3.0.0` to reflect the
interoperability of its API with the lua-argon2 implementation. In the future,
lua-argon2 and lua-argon2-ffi will continue sharing the same major version number
for similar versions.

### Changed

- :warning: This version is only compatible with Argon2
  [20160406](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20160406)
  and later.
- :warning: Renamed the `encrypt()` function to `hash_encoded()`, in order to
  carry a stronger meaning and to eventually implement a `hash_raw()` function
  in the future.
- New `variants` field with supported Argon2 encoding variants (as userdatum).
  See documentation and the "Added" section of this Changelog.
- Updated the default hashing options to match those of the Argon2 CLI:
  `t_cost = 3`, `m_cost = 4096`, `parallelism = 1`, `hash_len = 32`.

### Added

- :stars: Support for Argon2id encoding variant.
  [#24](https://github.com/thibaultcha/lua-argon2/pull/24)
- We now automatically compute the length of the retrieved encoded hash from
  `encrypt()`. [#21](https://github.com/thibaultcha/lua-argon2/pull/21)
- New option: `hash_len`.
  [#22](https://github.com/thibaultcha/lua-argon2/pull/22)
- Return errors from `verify()`. A mismatch now returns `false, nil`, while an
  error will return `nil, "err string"`.
  [#23](https://github.com/thibaultcha/lua-argon2/pull/23)

## [1.0.0] - 2016/04/10

### Added

- :stars: Support for Argon2
  [20160406](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20160406)
  (and later). The major version of this module has been bumped because the
  resulting hashes will not be backwards compatible.
- Performance improvements.
  [e9e6f9](https://github.com/thibaultcha/lua-argon2-ffi/commit/e9e6f9a609f40f9f26834364e05d701fbc0f9780)

## [0.0.1] - 2016/02/21

Initial release of this module for Argon2
[20151206](https://github.com/P-H-C/phc-winner-argon2/releases/tag/20151206).

[unreleased]: https://github.com/thibaultcha/lua-argon2-ffi/compare/3.0.1...master
[3.0.1]: https://github.com/thibaultcha/lua-argon2-ffi/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/thibaultcha/lua-argon2-ffi/compare/1.0.0...3.0.0
[1.0.0]: https://github.com/thibaultcha/lua-argon2-ffi/compare/0.0.1...1.0.0
[0.0.1]: https://github.com/thibaultcha/lua-argon2-ffi/compare/a2f94a08ec34bdd570ff707f5e2bebf87a60ba62...0.0.1
