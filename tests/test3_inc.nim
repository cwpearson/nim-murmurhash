# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import strutils

proc genSeq(n: int): seq[byte] =
    result = newSeq[byte](n)
    for i in 0..<n:
      result.add(byte(n-i))

import murmurhash
test "equal":
  check hash(1) == hash(1)
test "not equal":
  check hash(1) != hash(2)
test "equal to non-incremental (4)":
  check hash(1).hash == MurmurHash3_x64_128(1)
test "equal to non-incremental (15)":
  let a = genSeq(17)
  let p = cast[ptr byte](unsafeAddr a[0])
  check hash(p, 15).hash == MurmurHash3_x64_128(p, 15)
test "equal to non-incremental (16)":
  let a = genSeq(17)
  let p = cast[ptr byte](unsafeAddr a[0])
  check hash(p, 16).hash == MurmurHash3_x64_128(p, 16)
test "equal to non-incremental (17)":
  let a = genSeq(17)
  let p = cast[ptr byte](unsafeAddr a[0])
  check hash(p, 17).hash == MurmurHash3_x64_128(p, 17)