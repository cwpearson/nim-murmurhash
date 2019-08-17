# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import strutils

import murmurhash
test "equal":
  check MurmurHash3_x64_128(1) == MurmurHash3_x64_128(1)
test "not equal":
  check MurmurHash3_x64_128(1'u64) != MurmurHash3_x64_128(1'u32)
test "seed":
  check MurmurHash3_x64_128(1, 0) != MurmurHash3_x64_128(1, 1)
when cpuEndian == littleEndian:
  test "expected1":
    let a = MurmurHash3_x64_128("hello")
    check toHex(a[0]) & toHex(a[1]) == "CBD8A7B341BD9B025B1E906A48AE1D19"
    check int64(a[0]) == -3758069500696749310 # https://github.com/boydgreenfield/nimrod-murmur/blob/master/murmur3.nim
    check int64(a[1]) == 6565844092913065241 # https://github.com/boydgreenfield/nimrod-murmur/blob/master/murmur3.nim
  test "expected2":
    let a = MurmurHash3_x64_128("hello", 1)
    check toHex(a[0]) & toHex(a[1]) == "A78DDFF5ADAE8D10128900EF20900135"
