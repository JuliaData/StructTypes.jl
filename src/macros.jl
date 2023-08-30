isolate_name(name) = split(string(name), '.')[end]

for struct_type in (:Struct, :Mutable, :CustomStruct, :OrderedStruct, :AbstractType, :DictType, :ArrayType, :StringType, :NumberType, :BoolType, :NullType)
    @eval begin
        """
            @$(isolate_name($struct_type))(expr::Expr)
            @$(isolate_name($struct_type))(expr::Symbol)

        If `expr` is a struct definition, sets the `StructType` of the defined struct to
        `$(isolate_name($struct_type))()`. If `expr` is the name of a `Type`, sets the `StructType` of that
        type to `$(isolate_name($struct_type))()`.

        # Examples
        ```julia
        @$(isolate_name($struct_type)) MyStruct
        ```
        is equivalent to
        ```julia
        StructTypes.StructType(::Type{MyStruct}) = StructType.Struct()
        ```
        and
        ```julia
        @$(isolate_name($struct_type)) struct MyStruct
            val::Int
        end
        ```
        is equivalent to
        ```julia
        struct MyStruct
            val::Int
        end
        StructTypes.StructType(::Type{MyStruct}) = StructType.Struct()
        ```
        """ macro $struct_type(expr)
            return macro_constructor(expr, $struct_type)
        end
    end
end

function macro_constructor(expr::Expr, structtype)
    if expr.head == :struct
        return esc(quote
            $expr
            StructTypes.StructType(::Type{$(expr.args[2])}) = $structtype()
        end)
    else
        return :(throw(ArgumentError("StructType macros can only be used with a struct definition or a Type")))
    end
end
function macro_constructor(expr::Symbol, structtype)
    return esc(quote
        if $(expr) isa Type
            StructTypes.StructType(::Type{$(expr)}) = $structtype()
        else
            throw(ArgumentError("StructType macros can only be used with a struct definition or a Type"))
        end
    end)
end

"""
Macro to add subtypes for an abstract type without the need for type field.
For a given `abstract_type`` and `struct_subtype` generates custom lowered NameTuple
with all subtype fields and additional `StructTypes.subtypekey` field
used for identifying the appropriate concrete subtype.

usage:
```julia
abstract type Vehicle end
struct Car <: Vehicle
    make::String
end
StructTypes.subtypekey(::Type{Vehicle}) = :type
StructTypes.subtypes(::Type{Vehicle}) = (car=Car, truck=Truck)
StructTypes.@register_struct_subtype Vehicle Car
```
"""
macro register_struct_subtype(abstract_type, struct_subtype)
    AT = Core.eval(__module__, abstract_type)
    T = Core.eval(__module__, struct_subtype)
    field_name = StructTypes.subtypekey(AT)
    field_value = findfirst(x->x === T, StructTypes.subtypes(AT))
    x_names = [:(x.$(e)) for e in fieldnames(T)] # x.a, x.b, ...
    name_types = [:($n::$(esc(t))) for (n, t) in zip(fieldnames(T), fieldtypes(T))] # a::Int, b::String, ...
    quote
        StructTypes.StructType(::Type{$(esc(struct_subtype))}) = StructTypes.CustomStruct()
        StructTypes.lower(x::$(esc(struct_subtype))) = ($(esc(field_name)) = $(QuoteNode(field_value)), $(x_names...))
        StructTypes.lowertype(::Type{$(esc(struct_subtype))}) = @NamedTuple{$field_name::$(esc(Symbol)), $(name_types...)}
        $(esc(struct_subtype))(x::@NamedTuple{$field_name::$(esc(Symbol)), $(name_types...)}) = $(esc(struct_subtype))($(x_names...))
    end
end


#-----------------------------------------------------------------------------# @auto


"""
    @auto AbstractSuperType
    @auto AbstractSuperType _my_subtype_key_

Macro to automatically generate the StructTypes interface for every subtype of `AbstractSuperType`.
With the example of JSON3, this enables you to `JSON3.read(str, MyType)` where `MyType <: AbstractSuperType`.

The assumption is made that the
"""
macro auto(T, subtypekey = :__type__)
    esc(quote

        if $T isa UnionAll
            @warn "Cannot use @auto with UnionAll types."
        else
            function StructTypes.StructType(::Type{T}) where {T <: $T}
                isconcretetype(T) ? StructTypes.CustomStruct() : StructTypes.AbstractType()
            end

            function StructTypes.lower(x::T) where {T <: $T}
                ($subtypekey = Symbol(T), NamedTuple(k => getfield(x, k) for k in fieldnames(T))...)
            end

            function StructTypes.lowertype(::Type{T}) where {T <: $T}
                NamedTuple{($(QuoteNode(subtypekey)), fieldnames(T)...), Tuple{Symbol, fieldtypes(T)...}}
            end

            function StructTypes.construct(::Type{T}, nt::StructTypes.lowertype(Type{T})) where T <: $T
                T(nt[fieldnames(T)]...)
            end

            function StructTypes.subtypes(::Type{T}) where {T <: $T}
                StructTypes.SubTypeClosure() do x::Symbol
                    e = Meta.parse(string(x))
                    if StructTypes.is_valid_type_ex(e)
                        try     # try needed to catch undefined symbols
                            S = eval(e)
                            S isa Type && S <: T && return S
                        catch
                        end
                    end
                    return Any
                end
            end

            StructTypes.subtypekey(T::Type{<: $T}) = $(QuoteNode(subtypekey))
        end
    end)
end

is_valid_type_ex(x) = isbits(x)

is_valid_type_ex(s::Union{Symbol, QuoteNode}) = true

is_valid_type_ex(e::Expr) = ((e.head == :curly || e.head == :tuple || e.head == :.) && all(map(is_valid_type_ex, e.args)))
