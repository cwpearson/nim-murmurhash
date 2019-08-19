import bitops

import murmurhash/murmur2
import murmurhash/murmur3

export murmur2
export murmur3

# work on incremental hash
# adapted from https://github.com/aappleby/smhasher/blob/master/src/PMurHash.c

const   
    c1 = 0x87c37b91114253d5'u64
    c2 = 0x4cf5ad432745937f'u64

type MurmurHash = object
    hash: array[2, uint64]
    h1: uint64
    h2: uint64
    length: int
    carry: array[16, byte] # up to 15 bytes, byte 16 is size


template `^=`(a, b) = a = a xor b

template `+`*[T](p: ptr T, off: int): ptr T =
    cast[ptr T](cast[ByteAddress](p) +% off * sizeof(T))

template `[]`*[T](p: ptr T, off: int): T =
    (p + off)[]

proc fmix64 (x: uint64): uint64 {.inline, noinit.} =
    var k = x
    k ^= k shr 33
    k *= 0xff51afd7ed558ccd'u64
    k ^= k shr 33
    k *= 0xc4ceb9fe1a85ec53'u64
    k ^= k shr 33
    result = k

proc DoBlock(k1, k2, h1, h2: var uint64) =
    k1 *= c1
    k1 = rotateLeftBits(k1, 31);
    k1 *= c2
    h1 ^= k1

    h1 = rotateLeftBits(h1, 27)
    h1 += h2
    h1 = h1*5+0x52dce729

    k2 *= c2
    k2 = rotateLeftBits(k2, 33)
    k2 *= c1
    h2 ^= k2

    h2 = rotateLeftBits(h2, 31)
    h2 += h1
    h2 = h2*5+0x38495ab5

proc DoBytes(h: var MurmurHash, data: var ptr uint8, len: int) =
    # fold `len` bytes from `data` into carry

    var carryIdx = int(h.carry[^1])
    var dataIdx = 0

    var i = len

    while i > 0:
        h.carry[carryIdx] = data[dataIdx]
        carryIdx += 1
        dataIdx += 1
        i -= 1
        if carryIdx == 16:
            var k1 = cast[uint64](h.carry[0])
            var k2 = cast[uint64](h.carry[8])
            DoBlock(k1, k2, h.h1, h.h2)
            carryIdx = 0
    h.carry[^1] = byte(carryIdx)



proc Add*(h: MurmurHash, key: ptr uint8, len: int, seed: uint32 = 0): MurmurHash = 
    result = h

    # append bytes to carry, doing the hash if there are 16 bytes
    let nBytes = 16 - int(h.carry[^1])
    var data = key
    DoBytes(result, data, nBytes)

    # process the blocks, if there are any
    let nblocks = nBytes div 16
    var h1 = result.h1
    var h2 = result.h2

    let blocks = cast[ptr uint64](data);
    for i in 0 ..< nblocks:

        var k1 = blocks[i*2+0]
        var k2 = blocks[i*2+1]
        DoBlock(k1, k2, h1, h2)

    result.h1 = h1
    result.h2 = h2
    result.length += len

    # append leftover bytes into carry
    var tail = data + nblocks*16
    var nTailBytes = len and 15
    DoBytes(result, tail, nTailBytes)

    assert nTailBytes == 0


proc Finish*(h: MurmurHash): MurmurHash =

    # finish any bytes in the carry
    let tail = h.carry
    let len = int(h.carry[^1])

    var
        k1: uint64 = 0
        k2: uint64 = 0
        h2 = h.h2
        h1 = h.h1

    var state = len and 15
    while true:
        case state:
        of 15: k2 ^= tail[14].uint64 shl 48
        of 14: k2 ^= tail[13].uint64 shl 40
        of 13: k2 ^= tail[12].uint64 shl 32
        of 12: k2 ^= tail[11].uint64 shl 24
        of 11: k2 ^= tail[10].uint64 shl 16
        of 10: k2 ^= tail[9].uint64 shl 8
        of 9:
            k2 ^= tail[8].uint64 shl 0
            k2 *= c2
            k2 = rotateLeftBits(k2, 33)
            k2 *= c1
            h2 ^= k2
        of 8: k1 ^= tail[7].uint64 shl 56
        of 7: k1 ^= tail[6].uint64 shl 48
        of 6: k1 ^= tail[5].uint64 shl 40
        of 5: k1 ^= tail[4].uint64 shl 32
        of 4: k1 ^= tail[3].uint64 shl 24
        of 3: k1 ^= tail[2].uint64 shl 16
        of 2: k1 ^= tail[1].uint64 shl 8
        of 1:
            k1 ^= tail[0].uint64 shl 0
            k1 *= c1
            k1 = rotateLeftBits(k1, 31)
            k1 *= c2
            h1 ^= k1
        of 0: break
        else:
            assert false
        dec(state)

    # finalization

    h1 ^= (len + h.length).uint64
    h2 ^= (len + h.length).uint64

    h1 += h2
    h2 += h1

    h1 = fmix64(h1)
    h2 = fmix64(h2)

    h1 += h2
    h2 += h1

    result.hash[0] = h1
    result.hash[1] = h2


proc `!&`(h: MurmurHash; val: int): MurmurHash =
    ## Mixes a hash value h with val to produce a new hash value.
    ## This is only needed if you need to implement a hash proc for a new datatype.

    # use previous hash as a seed for the new hash
    let data = cast[ptr uint8](val)
    let n = sizeof(int)
    result = Add(h, data, n)

proc `!$`(h: MurmurHash): MurmurHash =
    ## Finishes the computation of the hash value.
    ## This is only needed if you need to implement a hash proc for a new datatype.
    Finish(h)

# type Something = object
#     x: int
#     y: float

# proc hash(x: Something): MurmurHash =
#     ## Computes a Hash from `x`.
#     var h: MurmurHash = 0
#     # Iterate over parts of `x`.
#     h = h !& x.x
#     h = h !& x.y
#     result = !$h