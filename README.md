# nim-murmur

[![Build Status](https://travis-ci.org/cwpearson/nim-murmur.svg?branch=master)](https://travis-ci.org/cwpearson/nim-murmur)

A pure-nim implementation of MurmurHash

Adapted from https://github.com/aappleby/smhasher

## Using

put something like

```
requires "https://github.com/cwpearson/nim-murmur#1fce9fd"
```

in your nimble file, and then

```nim
import murmur
```

## About

Only two functions implemented currently.

- Murmur3
  - [x] MurmurHash3_x64_128
  - [ ] MurmurHash3_x86_32
  - [ ] MurmurHash3_x86_128
- Murmur2
  - [x] MurmurHash64A - The original 64-bit version. Optimized for 64-bit arithmetic.
  - [ ] MurmurHash2 - The original version; contains a flaw that weakens collision in some cases.
  - [ ] MurmurHash2A - A fixed variant using Merkle–Damgård construction construction. Slightly slower.
  - [ ] CMurmurHash2A - MurmurHash2A but works incrementally.
  - [ ] MurmurHashNeutral2 - Slower, but endian and alignment neutral.
  - [ ] MurmurHashAligned2 - Slower, but does aligned reads (safer on some platforms).
  - [ ] MurmurHash64B (64-bit, x86) - A 64-bit version optimized for 32-bit platforms. Unfortunately it is not a true 64-bit hash due to insufficient mixing of the stripes.
- Murmur
  - [ ] MurmurHash1

## Related:

A murmur3 is implemented in [vitanim](https://github.com/timotheecour/vitanim/blob/master/murmur/murmur.nim) by timotheecour