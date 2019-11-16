using Documenter, StructTypes

makedocs(;
    modules=[StructTypes],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/quinnj/StructTypes.jl/blob/{commit}{path}#L{line}",
    sitename="StructTypes.jl",
    authors="Jacob Quinn",
    assets=String[],
)

deploydocs(;
    repo="github.com/quinnj/StructTypes.jl",
)
