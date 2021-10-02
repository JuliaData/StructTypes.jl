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