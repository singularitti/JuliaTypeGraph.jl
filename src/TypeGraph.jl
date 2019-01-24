"""
# module TypeGraph

Taken from [Google Groups](https://groups.google.com/forum/#!msg/julia-users/ECkQa8vAkko/6tqVeWrexr4J).
A short julia program that generates the graph of all subtypes of a given type, in png format by default.
Uses `graphviz`.

# Examples

```jldoctest
julia> makegraph(Number, "result.dot")
=> Result here: https://imgur.com/a/CkoOA#0
julia> makegraph(Any, "alltypes.dot", "svg")
=> Result here: https://imgur.com/U5vTDNp
```
"""
module TypeGraph

using InteractiveUtils

export makegraph

isalnum(c) = isletter(c) || isnumeric(c)

function typeit(fn, typ)
    seen = Dict{Type,Bool}()
    function apply(fn, tp)
        if !get(seen, tp, false)
            seen[tp] = true
            for child in subtypes(tp)
                fn(tp, child)
                apply(fn, child)
            end
        end
    end
    apply(fn, typ)
    collect(keys(seen))
end

function edge(typ1, typ2)
    let convert = typ->map(x->if isalnum(x) x else '_' end, string(typ))
        c1 = convert(typ1)
        c2 = convert(typ2)
        if c2 == "Graph" ; c2 = "G;\nG [label=\"Graph\"]" ; end
        "$(c1) -> $(c2);\n"
    end
end

const graphviz_formats = ["png","gif","svg","jpg","svgz","pcl", "mif", "pcl", "dia", "ps","fig", "imap","cmapx"]

function makegraph(typ, file, format = "png")
    if !in(format, graphviz_formats)
        println("Warning: the output format may not be supported by graphviz.\nHere are the default formats:\n$(join(graphviz_formats, " "))")
    end
    open(file, "w") do f
        write(f, "digraph{\n")                # oriented graph
        write(f, "rankdir=LR\n")              # layout of the graph from left to right
        typeit((x, y)->write(f, edge(x, y)), typ)
        write(f, "}")
    end
    run(`dot -T$(format) -O $file`)        # graphviz needed here.
end

end # module
