
from os.env import getenv, setenv
from random import random_si64
from memory import bitcast

@always_inline
fn _DJBX33A_SECRET() -> UInt64:
    """Example how secret and seed can be stored and retrieved."""
    try:
        var secret_string = getenv("DJBX33A_SECRET", "")
        return bitcast[DType.uint64](Int64(int(secret_string)))
    except:
        var value = random_si64(Int64.MIN, Int64.MAX)
        _ = setenv("DJBX33A_SECRET", str(value))
        return bitcast[DType.uint64](value)

struct DJBX33A_Hasher[custom_secret: UInt64 = 0]:
    """Example of a simple Hasher, with an option to provide a custom secret at compile time.
    When custom secret is set to 0 the secret will be looked up in env var DJBX33A_SECRET. 
    In case env var DJBX33A_SECRET is not set a random int will be generated."""
    var hash_data: UInt64
    var secret: UInt64

    @always_inline
    fn __init__(inout self):
        self.hash_data = 5361
        @parameter
        if custom_secret != 0:
            self.secret = custom_secret
        else:
            self.secret = _DJBX33A_SECRET()

    @always_inline
    fn _update_with_bytes(inout self, bytes: UnsafePointer[UInt8], n: Int):
        """The algorithm is not optimal."""
        for i in range(n):
            # self.hash_data = self.hash_data * 33 + val_to_load.load(bytes, offset=i).cast[DType.uint64]()
            # self.hash_data = self.hash_data * 33 + Scalar[DType.uint8]().load(bytes, offset=i).cast[DType.uint64]()
            self.hash_data = self.hash_data * 33 + bytes[i].cast[DType.uint64]()

    @always_inline
    fn _update_with_simd[dt: DType, size: Int](inout self, value: SIMD[dt, size]):
        """The algorithm is not optimal."""
        alias size_in_bytes = size * dt.sizeof()
        var bytes = bitcast[DType.uint8, size_in_bytes](value)
        @parameter
        for i in range(size_in_bytes):
            self.hash_data = self.hash_data * 33 + bytes[i].cast[DType.uint64]()

    @always_inline
    fn _finish[dt: DType = DType.uint64](owned self) -> Scalar[dt]:
        return (self.hash_data ^ self.secret).cast[dt]()

@value
struct ArbiterKey(KeyElement):
    var b1: Int64
    var b2: Int64
    var hash_data: UInt64

    fn __init__(inout self, b1: Int, b2: Int):
        self.b1 = b1
        self.b2 = b2
        var tmp: SIMD[DType.int64, 2]
        if b1 < b2:
            tmp = SIMD[DType.int64, 2](b1, b2)
        else:
            tmp = SIMD[DType.int64, 2](b2, b1)

        var hasher = DJBX33A_Hasher()
        hasher._update_with_simd(tmp)

        self.hash_data = hasher^._finish()

    @always_inline
    fn __hash__(self) -> UInt:
        return int(self.hash_data)

    @always_inline
    fn __eq__(self, other: ArbiterKey) -> Bool:
        if hash(self) == hash(other):
            return True
        return False

    @always_inline    
    fn __ne__(self, other: ArbiterKey) -> Bool:
        if hash(self) != hash(other):
            return True
        return False

    @always_inline
    fn __str__(self) -> String:
        return "b1: " + hex(self.b1) + ", b2:" + hex(self.b2)
