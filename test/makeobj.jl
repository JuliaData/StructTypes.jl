@testset "makeobj" begin
    @testset "makeobj" begin
        cases = [
            (Any,               String,            "foo"),
            (AbstractString,    String,            "foo"),
            (String,            String,            "foo"),
            (SubString,         SubString{String}, "foo"),
            (SubString{String}, SubString{String}, "foo"),
            (Any,               Int,               1),
            (Real,              Int,               1),
            (Integer,           Int,               1),
            (Int,               Int,               1),
            (Any,               Vector{Int},       [1, 2, 3]),
            (Vector,            Vector{Int},       [1, 2, 3]),
            (Vector{Any},       Vector{Any},       [1, 2, 3]),
            (Vector{Real},      Vector{Real},      [1, 2, 3]),
            (Vector{Integer},   Vector{Integer},   [1, 2, 3]),
            (Vector{Int},       Vector{Int},       [1, 2, 3]),
            (Any,               Dict{Symbol, Int}, Dict(:a => 1, :b => 2)),
            (AbstractDict,      Dict{Symbol, Int}, Dict(:a => 1, :b => 2)),
            (Dict,              Dict{Symbol, Int}, Dict(:a => 1, :b => 2)),
            (Dict{Any, Any},    Dict{Any, Any},    Dict(:a => 1, :b => 2)),
            (Dict{Symbol, Any}, Dict{Symbol, Any}, Dict(:a => 1, :b => 2)),
            (Dict{Any, Int},    Dict{Any, Int},    Dict(:a => 1, :b => 2)),
            (Dict{Symbol, Int}, Dict{Symbol, Int}, Dict(:a => 1, :b => 2)),
        ]
        for case in cases
            a = case[1]
            b = case[2]
            c = case[3]
            @test typeof(StructTypes.makeobj(a, c)) === b
            @test StructTypes.makeobj(a, c) == c
        end
    end
    @testset "mutable structs" begin
        @testset "makeobj" begin
            input = Dict(:a => 1, :b => 2.0, :c => "three")
            output = StructTypes.makeobj(C, input)
            @test typeof(output) === C
            @test output.a == 1
            @test output.b == 2.0
            @test output.c == "three"
        end
        @testset "makeobj!" begin
            input = Dict(:a => 1, :b => 2.0, :c => "three")
            x = C()
            output = StructTypes.makeobj!(x, input)
            @test x === output
            @test typeof(x) === C
            @test x.a == 1
            @test x.b == 2.0
            @test x.c == "three"
        end
    end
end
