
template `^=`(a, b) = a = a xor b

template `+`*[T](p: ptr T, off: int): ptr T =
    cast[ptr T](cast[ByteAddress](p) +% off * sizeof(T))

template `[]`*[T](p: ptr T, off: int): T =
    (p + off)[]


proc MurmurHash64A*(key: ptr uint8, len: int, seed: uint64 = 0): uint64 =
    ## MurmurHash2
    ## https://github.com/aappleby/smhasher/blob/master/src/MurmurHash2.cpp
    let m = 0xc6a4a7935bd1e995'u64
    let r = 47

    var h = seed xor uint64(uint64(len) * m)

    let blocks = cast[ptr uint64](key)
    let nblocks = len div sizeof(uint64)

    for i in 0 ..< nblocks:
        var k = blocks[i]
        # echo &"i,k: {i},{k}"
        k *= m
        k ^= k shr r
        k *= m
        h ^= k
        h *= m

    let tail = key + nblocks * sizeof(uint64)
    var state = len and 7
    while state > 0:
        case state:
        of 7: h ^= uint64(tail[6]) shl 48
        of 6: h ^= uint64(tail[5]) shl 40
        of 5: h ^= uint64(tail[4]) shl 32
        of 4: h ^= uint64(tail[3]) shl 24
        of 3: h ^= uint64(tail[2]) shl 16
        of 2: h ^= uint64(tail[1]) shl 8
        of 1:
            h ^= uint64(tail[0])
            h *= m
        of 0: break
        else:
            assert false
        dec(state)

    h ^= h shr r
    h *= m
    h ^= h shr r

    result = h
    # echo &"{bytes},{seed} -> {result}"

proc MurmurHash64A*(x: string, seed = 0'u64): auto =
    MurmurHash64A(cast[ptr uint8](x[0].unsafeAddr), x.len, seed)

proc MurmurHash64A*[T: SomeInteger](x: T, seed = 0'u64): auto =
    MurmurHash64A(cast[ptr uint8](x.unsafeAddr), sizeof(x), seed)

proc MurmurHash64A*(x: pointer, len: int, seed = 0'u64): auto =
    MurmurHash64A(cast[ptr uint8](x), len, seed)

proc MurmurHash64A*[T](x: openArray[T], seed = 0'u64): auto =
    let data = unsafeAddr x[0]
    let len = len(x) * sizeof(T)
    MurmurHash64A(data, len, seed)

when isMainModule:
    import times
    import strformat


    proc toSeconds(d: Duration): float =
        float(d.inNanoseconds) / 1e9

    let bytes = 10_000_000
    let a = newSeq[byte](bytes)

    for i in 0..4:
        let start = now()
        discard MurmurHash64A(a)
        let elapsed = toSeconds(now() - start)
        echo &"{float(bytes) / elapsed / 1024 / 1024:2.2e} MB/s"
