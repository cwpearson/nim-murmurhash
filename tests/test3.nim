# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import murmur
test "equal":
  check MurmurHash3_x64_128(1) == MurmurHash3_x64_128(1)
test "not equal":
  check MurmurHash3_x64_128(1'u64) != MurmurHash3_x64_128(1'u32)
test "seed":
  check MurmurHash3_x64_128(1, 0) != MurmurHash3_x64_128(1, 1)
