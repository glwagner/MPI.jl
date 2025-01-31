using Documenter
using MPI

# generate example markdown
EXAMPLES = [
    "Hello world" => "examples/01-hello.md",
    "Broadcast" => "examples/02-broadcast.md",
    "Reduce" => "examples/03-reduce.md",
    "Send/receive" => "examples/04-sendrecv.md",
    "Job Scheduling" => "examples/05-job_schedule.md",
    "Scatterv and Gatherv" => "examples/06-scatterv.md",
]

examples_md_dir = joinpath(@__DIR__,"src/examples")
isdir(examples_md_dir) || mkdir(examples_md_dir)

for (example_title, example_md) in EXAMPLES
    example_jl = example_md[1:end-2]*"jl"
    @info "Building $example_md"
    open(joinpath(@__DIR__, "src", example_md), "w") do mdfile
        println(mdfile, """
            ```@meta
            EditURL = "https://github.com/JuliaParallel/MPI.jl/blob/master/docs/$(example_jl)"
            ```
            """
        )
        println(mdfile, "# $example_title")
        println(mdfile)
        println(mdfile, "```julia")
        println(mdfile, "# $example_jl")
        println(mdfile, readchomp(joinpath(@__DIR__,example_jl)))
        println(mdfile, "```")
        println(mdfile)

        println(mdfile, "```")
        println(mdfile, "> mpiexecjl -n 3 julia $example_jl")
        cd(@__DIR__) do
            write(mdfile, mpiexec(cmd -> read(`$cmd -n 3 $(Base.julia_cmd()) --project $example_jl`)))
        end
        println(mdfile, "```")
    end
end

DocMeta.setdocmeta!(MPI, :DocTestSetup, :(using MPI); recursive=true)

makedocs(
    sitename = "MPI.jl",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    modules = [MPI],
    pages = Any[
        "index.md",
        "configuration.md",
        "usage.md",
        "knownissues.md",
        "Examples" => EXAMPLES,
        "Reference" => [
            "library.md",
            "environment.md",
            "comm.md",
            "buffers.md",
            "pointtopoint.md",
            "collective.md",
            "onesided.md",
            "topology.md",
            "io.md",
            "advanced.md",
        ],
        "refindex.md",
    ]
)

deploydocs(
    repo = "github.com/JuliaParallel/MPI.jl.git",
    push_preview = true,
)
