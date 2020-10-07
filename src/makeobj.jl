"""
    makeobj(::Type{Any}, obj::Any)

Return `obj`.
"""
makeobj(::Type{Any}, obj) = obj

"""
    makeobj(::Type{Any}, obj::AbstractDict)

Return `obj`.
"""
makeobj(::Type{Any}, obj::AbstractDict) = obj

"""
    makeobj(::Type{T}, obj::Any)

Convert `obj` to an object of `T`.
"""
makeobj(::Type{T}, obj) where {T <: Any} = convert(T, obj)::T

"""
    makeobj(::Type{T}, obj::AbstractDict) where {T <: AbstractDict}

Convert `obj` to an object of `T`.
"""
makeobj(::Type{T}, obj::AbstractDict) where {T <: AbstractDict} = convert(T, obj)::T

"""
    makeobj(::Type{T}, obj::AbstractDict) where {T}

Convert `obj` to an object of `T`. `T` must be a mutable struct.
"""
function makeobj(::Type{T}, obj::AbstractDict) where {T}
    x = T()
    makeobj!(x, obj)
    return x
end

"""
    makeobj!(x::T, obj::AbstractDict) where {T}

Populate the fields of `x` with the values from `obj`. `T` must be a mutable struct.
"""
function makeobj!(x::T, obj::AbstractDict) where {T}
    for (k, v) in obj
        if hasfield(T, k)
            setfield!(x, k, makeobj(fieldtype(T, k), v))
        end
    end
    return x
end
