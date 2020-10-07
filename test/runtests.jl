using Test, StructTypes, UUIDs, Dates

struct A
    x::Int
end

struct DictWrapper
    x::Dict
end

@enum Fruit apple orange

@testset "StructTypes" begin

@test StructTypes.StructType(Union{Int, Missing}) == StructTypes.Struct()
@test StructTypes.StructType(Any) == StructTypes.Struct()
@test StructTypes.StructType(A) == StructTypes.NoStructType()
@test StructTypes.StructType(A(1)) == StructTypes.NoStructType()

@test StructTypes.names(A) == ()
@test StructTypes.names(A(1)) == ()

@test StructTypes.julianame(((:a, :A), (:b, :B)), :B) == :b
@test StructTypes.serializationname(((:a, :A), (:b, :B)), :b) == :B

@test StructTypes.excludes(A) == ()
@test StructTypes.excludes(A(1)) == ()

@test StructTypes.omitempties(A) == ()
@test StructTypes.omitempties(A(1)) == ()

@test StructTypes.isempty([])
@test StructTypes.isempty(Dict())
@test StructTypes.isempty("")
@test StructTypes.isempty(())
@test StructTypes.isempty(NamedTuple())
@test !StructTypes.isempty(1)
@test StructTypes.isempty(nothing)
@test !StructTypes.isempty(A(1))
@test !StructTypes.isempty(A(1), 1)

@test StructTypes.keywordargs(A) == NamedTuple()
@test StructTypes.keywordargs(A(1)) == NamedTuple()

@test StructTypes.idproperty(A) == :_
@test StructTypes.idproperty(A(1)) == :_

@test StructTypes.StructType(Dict) == StructTypes.DictType()
@test StructTypes.StructType(NamedTuple) == StructTypes.DictType()
@test StructTypes.StructType(Pair) == StructTypes.DictType()

x = Dict(1 => 2)
@test StructTypes.keyvaluepairs(x) == pairs(x)
x = 1 => 2
@test StructTypes.keyvaluepairs(x) == (x,)

x = Dict(:hey => 2)
@test StructTypes.construct(typeof(x), x) === x
y = DictWrapper(x)
@test StructTypes.construct(DictWrapper, x) == y

@test StructTypes.construct(NamedTuple, x) == (hey=2,)
@test StructTypes.construct(NamedTuple{(:hey,)}, x) == (hey=2,)
@test StructTypes.construct(NamedTuple{(:hey,),Tuple{Int}}, x) == (hey=2,)

@test StructTypes.StructType(Vector) == StructTypes.ArrayType()
@test StructTypes.StructType(Set) == StructTypes.ArrayType()
@test StructTypes.StructType(Tuple) == StructTypes.ArrayType()

@test StructTypes.construct(Tuple, [1, 2]) == (1, 2)

@test StructTypes.StructType(String) == StructTypes.StringType()
@test StructTypes.StructType(Symbol) == StructTypes.StringType()
@test StructTypes.StructType(Enum) == StructTypes.StringType()
@test StructTypes.StructType(Char) == StructTypes.StringType()
@test StructTypes.StructType(UUID) == StructTypes.StringType()
@test StructTypes.StructType(Date) == StructTypes.StringType()

@test StructTypes.construct(Char, "1") == '1'
@test_throws ArgumentError StructTypes.construct(Char, "11")

@test StructTypes.construct(Fruit, :apple) == apple
@test StructTypes.construct(Fruit, "apple") == apple
x = "apple"
@test StructTypes.construct(Fruit, pointer(x), 5) == apple

@test StructTypes.construct(Symbol, "hey") == :hey
@test StructTypes.construct(Symbol, pointer(x), 5) == :apple
x = "499beb72-22ea-11ea-3366-55749430b981"
@test StructTypes.construct(UUID, pointer(x), 36) == UUID(x)
@test StructTypes.construct(Date, "11-30-2019"; dateformat=dateformat"mm-dd-yyyy") == Date(2019, 11, 30)

@test StructTypes.StructType(UInt8) == StructTypes.NumberType()
@test StructTypes.StructType(Int8) == StructTypes.NumberType()
@test StructTypes.StructType(Float64) == StructTypes.NumberType()
@test StructTypes.numbertype(UInt8) == UInt8
@test StructTypes.numbertype(Complex) == Float64

@test StructTypes.construct(Float64, 1) === 1.0

@test StructTypes.StructType(Bool) == StructTypes.BoolType()
@test StructTypes.construct(Int, true) == 1

@test StructTypes.StructType(Nothing) == StructTypes.NullType()
@test StructTypes.StructType(Missing) == StructTypes.NullType()
@test StructTypes.construct(Missing, nothing) === missing

@test StructTypes.subtypekey(A) == :type
@test StructTypes.subtypekey(A(1)) == :type
@test StructTypes.subtypes(A) == NamedTuple()
@test StructTypes.subtypes(A(1)) == NamedTuple()

end

struct B
    a::Int
    b::Float64
    c::String
end

mutable struct C
    a::Int
    b::Float64
    c::String
    C() = new()
    C(a::Int, b::Float64, c::String) = new(a, b, c)
end

struct LotsOfFields
    x1::String
    x2::String
    x3::String
    x4::String
    x5::String
    x6::String
    x7::String
    x8::String
    x9::String
    x10::String
    x11::String
    x12::String
    x13::String
    x14::String
    x15::String
    x16::String
    x17::String
    x18::String
    x19::String
    x20::String
    x21::String
    x22::String
    x23::String
    x24::String
    x25::String
    x26::String
    x27::String
    x28::String
    x29::String
    x30::String
    x31::String
    x32::String
    x33::String
    x34::String
    x35::String
end

mutable struct LotsOfFields2
    x1::String
    x2::String
    x3::String
    x4::String
    x5::String
    x6::String
    x7::String
    x8::String
    x9::String
    x10::String
    x11::String
    x12::String
    x13::String
    x14::String
    x15::String
    x16::String
    x17::String
    x18::String
    x19::String
    x20::String
    x21::String
    x22::String
    x23::String
    x24::String
    x25::String
    x26::String
    x27::String
    x28::String
    x29::String
    x30::String
    x31::String
    x32::String
    x33::String
    x34::String
    x35::String
    LotsOfFields2() = new()
end

mutable struct DateStruct
    date::Date
    datetime::DateTime
    time::Time
end
DateStruct() = DateStruct(Date(0), DateTime(0), Time(0))
Base.:(==)(a::DateStruct, b::DateStruct) = a.date == b.date && a.datetime == b.datetime && a.time == b.time

@testset "convenience functions" begin

## StructTypes.construct
# simple struct
@test StructTypes.construct((i, nm, T) -> 1, A) == A(1)
@inferred StructTypes.construct((i, nm, T) -> 1, A)

# hetero fieldtypes struct
@test StructTypes.construct((i, nm, T) -> (1, 3.14, "hey")[i], B) == B(1, 3.14, "hey")
@inferred StructTypes.construct((i, nm, T) -> (1, 3.14, "hey")[i], B)

# simple tuple
@test StructTypes.construct((i, nm, T) -> 1, Tuple{Int}) == (1,)
@inferred StructTypes.construct((i, nm, T) -> 1, Tuple{Int})

# hetero fieldtypes tuple
@test StructTypes.construct((i, nm, T) -> (1, 3.14, "hey")[i], Tuple{Int, Float64, String}) == (1, 3.14, "hey")
@inferred StructTypes.construct((i, nm, T) -> (1, 3.14, "hey")[i], Tuple{Int, Float64, String})

# > 32 fields
vals = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
@test StructTypes.construct((i, nm, T) -> vals[i], LotsOfFields) == LotsOfFields(vals...)

StructTypes.names(::Type{A}) = ((:x, :y),)
StructTypes.construct(A) do i, nm, T
    @test nm == :y
    1
end

StructTypes.keywordargs(::Type{DateStruct}) = (date=(dateformat=dateformat"mm/dd/yyyy",),)
f(i, nm, T; dateformat=Dates.ISODateFormat) = nm == :date ? Date("11/23/1961", dateformat) : nm == :datetime ? DateTime(0) : Time(0)
@test StructTypes.construct(f, DateStruct) == DateStruct(Date(1961, 11, 23), DateTime(0), Time(0))

StructTypes.names(::Type{LotsOfFields}) = ((:x35, :y35),)
StructTypes.keywordargs(::Type{LotsOfFields}) = (x35=(hey=:ho,),)
function f1(i, nm, T; hey=:hey)
    if i == 35
        @test nm == :y35
        @test hey == :ho
    end
    return vals[i]
end
@test StructTypes.construct(f1, LotsOfFields) == LotsOfFields(vals...)

## StructTypes.foreachfield
StructTypes.foreachfield(A(1)) do i, nm, T, v
    @test v == 1
    @test nm == :y
end
StructTypes.foreachfield((i, nm, T, v) -> @test((1, 3.14, "hey")[i] == v), B(1, 3.14, "hey"))
function f2(i, nm, T, v; hey=:hey)
    if i == 35
        @test nm == :y35
        @test hey == :ho
    end
    @test vals[i] == v
end
StructTypes.foreachfield(f2, LotsOfFields(vals...))

x = C()
StructTypes.mapfields!((i, nm, T) -> (1, 3.14, "hey")[i], x)
x2 = C(1, 3.14, "hey")
@test x.a == x2.a && x.b == x2.b && x.c == x2.c

x = LotsOfFields2()
StructTypes.mapfields!((i, nm, T) -> vals[i], x)
x2 = LotsOfFields(vals...)
StructTypes.foreachfield((i, nm, T, v) -> @test(getfield(x, i) == getfield(x2, i)), x)

@test StructTypes.applyfield!((i, nm, T) -> "ho", x, :x1)
@test x.x1 == "ho"
# non-existant field
@test !StructTypes.applyfield!((i, nm, T) -> "ho", x, :y1)

x2 = C(1, 3.14, "")
StructTypes.omitempties(::Type{C}) = (:c,)
StructTypes.foreachfield(x2) do i, nm, T, v
    @test i != 3
    @test nm != :c
end
StructTypes.excludes(::Type{C}) = (:a,)
StructTypes.foreachfield(x2) do i, nm, T, v
    @test i != 1
    @test nm != :a
end
# field isn't applied if excluded
@test !StructTypes.applyfield!((i, nm, T) -> "ho", x2, :a)

# field isn't set if excluded
x2.a = 10
StructTypes.mapfields!((i, nm, T) -> (1, 3.14, "hey")[i], x2)
@test x2.a == 10 && x2.b == 3.14 && x2.c == "hey"

end

include("makeobj.jl")
