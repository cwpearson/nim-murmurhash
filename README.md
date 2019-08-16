# murmur

A pure-nim implementation of murmur hash

Adapted from https://github.com/aappleby/smhasher

- Murmur3
  - [ ] MurmurHash3_x86_32
  - [ ] MurmurHash3_x86_128 (see [vitanim](https://github.com/timotheecour/vitanim/blob/master/murmur/murmur.nim))
- Murmur2
  - [ ] MurmurHash2 (32-bit, x86) - The original version; contains a flaw that weakens collision in some cases.
  - [ ] MurmurHash2A (32-bit, x86) - A fixed variant using Merkle–Damgård construction construction. Slightly slower.
  - [ ] CMurmurHash2A (32-bit, x86) - MurmurHash2A but works incrementally.
  - [ ] MurmurHashNeutral2 (32-bit, x86) - Slower, but endian and alignment neutral.
  - [ ] MurmurHashAligned2 (32-bit, x86) - Slower, but does aligned reads (safer on some platforms).
  - [x] MurmurHash64A (64-bit, x64) - The original 64-bit version. Optimized for 64-bit arithmetic.
  - [ ] MurmurHash64B (64-bit, x86) - A 64-bit version optimized for 32-bit platforms. Unfortunately it is not a true 64-bit hash due to insufficient mixing of the stripes.
- Murmur