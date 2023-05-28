module JuliaTutorial

using InteractiveUtils, BenchmarkTools

include("./dep/07_AdvancedTypes.jl")
include("./dep/08_solve_cubic.jl")

greet() = print("Hello World!")

export Order0, Order1, Order2

export derivative, nth_derivative, nth_generated


end # module
