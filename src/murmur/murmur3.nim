import bitops

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


proc MurmurHash3_x64_128*(key: ptr uint8, len: int, seed: uint32 = 0): array[2, uint64] =

    let data = cast[ptr uint8](key)
    let nblocks = len div 16

    var h1 = uint64(seed);
    var h2 = uint64(seed);

    let c1 = 0x87c37b91114253d5'u64
    let c2 = 0x4cf5ad432745937f'u64

    # body

    let blocks = cast[ptr uint64](data);
    for i in 0 ..< nblocks:


        var k1 = blocks[i*2+0]
        var k2 = blocks[i*2+1]

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


    # tail

    let tail = data + nblocks*16

    var
        k1: uint64 = 0
        k2: uint64 = 0

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

    h1 ^= len.uint64
    h2 ^= len.uint64

    h1 += h2
    h2 += h1

    h1 = fmix64(h1)
    h2 = fmix64(h2)

    h1 += h2
    h2 += h1

    result[0] = h1
    result[1] = h2

proc MurmurHash3_x64_128*(x: string, seed = 0'u32): auto =
    MurmurHash3_x64_128(cast[ptr uint8](x[0].unsafeAddr), x.len, seed)

proc MurmurHash3_x64_128*[T: SomeInteger](x: T, seed = 0'u32): auto =
    MurmurHash3_x64_128(cast[ptr uint8](x.unsafeAddr), sizeof(x), seed)

proc MurmurHash3_x64_128*(x: pointer, len: int, seed = 0'u32): auto =
    MurmurHash3_x64_128(cast[ptr uint8](x), len, seed)

proc MurmurHash3_x64_128*[T](x: openArray[T], seed = 0'u32): auto =
    let data = unsafeAddr x[0]
    let len = len(x) * sizeof(T)
    MurmurHash3_x64_128(data, len, seed)

when isMainModule:
    import times
    import strformat


    proc toSeconds(d: Duration): float =
        float(d.inNanoseconds) / 1e9

    let bytes = 10_000_000
    let a = newSeq[byte](bytes)

    for i in 0..4:
        let start = now()
        discard MurmurHash3_x64_128(a)
        let elapsed = toSeconds(now() - start)
        echo &"{float(bytes) / elapsed / 1024 / 1024:2.2e} MB/s"
