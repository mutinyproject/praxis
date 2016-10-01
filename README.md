# musl-compat

A set of headers and small utilities for use on musl libc systems, for providing
some minimal glibc compatibility.

Some of these things are taken from Alpine Linux's musl package.

`libintl.a` is provided so that programs which specify `-lintl` when linking
don't fail, but use musl's `libintl` implementation anyway. musl itself uses
the same method for `libm`, `librt`, `libpthread`, `libcrypt`...

# Licences

### MIT
- `include/sys/cdefs.h`

### 2-clause BSD
- `gencat.c`
- `getconf.c`
- `getent.c`
- `include/sys/tree.h`

### 3-clause BSD
- `include/sys/queue.h`
- `include/sys/tree.h`

## Related

- [musl-fts](https://github.com/pullmoll/musl-fts)
- [musl-obstack](https://github.com/pullmoll/musl-obstack)

