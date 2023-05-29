# https://julialang.org/

# https://julialang.org/downloads/

# https://www.julia-vscode.org/

# https://juliacomputing.com/

# https://www.youtube.com/user/JuliaLanguage

# https://julia.quantecon.org/intro.html

# https://docs.julialang.org

# https://docs.julialang.org/en/v1/manual/performance-tips/

# This is a comment
#= This is 
another comment =#

#= How to use julia

    1. Interactively from the REPL
    2. Interactively from vs-code
    3. Using julia scripts: `julia mycode.jl`
        * Can also run scripts by doing `include("mycode.jl")` from within a julia session
    4. Jupyter notebooks (https://jupyter.org/, see IJulia below)

=#

versioninfo() # more information

#= Available from the REPL
    * ] enters package manager
    * ; activate the shell
    * ? help mode
    * arrows to navigate
    * Useful shortcuts
        - ctrl+c stops execution
        - ctrl+l cleans console
        - ctrl+d kills istance (equivalent to `exit()`)
=#

#= Unicode support

    \alpha (+ press Tab)
    \int (+ press Tab)
    \:whale: (+ press Tab)
    \:pizza: (+ press Tab)
    \:hamburger: (+ press Tab)
    🍕 > 🍔
    \pi (+ press Tab)            # returns 3.14...
    \euler (+ press Tab)         # returns 2.71...
    Base.MathConstants.golden
=#


# Here is where unicode is super cool
∑(x,y) = x + y
∑(1,2)

ans # can use as any other variable
ans; # suppress output
ans+1

println(ans)
println("I like economics")
println("""I like economics "with" quotes""")

#= Package manager
    * ] status 
    * ] add PackageName
    * ] up PackageName
    * ] rm PackageName
    * ] pin PackageName@ver
    * ] free PackageName

    using Pkg
    Pkg.add("PackageName")
    Pkg.update("PackageName) 
    etc...
=#

#= Why packages? =#

using PyPlot

# List of packages https://pkg.julialang.org/

# Suggested packages
Revise
BenchmarkTools
TimerOutputs
ProfileView
Plots
Gadfly
DataFrames
Distributions
StatsBase
PyCall
Pandas
Flux    # Machine learning
Zygote  # Automatic differentiation
ForwardDiff
JuMP    # Numerical optimization
Optim   # Numerical optimization
NLOpt
Parameters
DifferentialEquations
CSV
Pluto
Debugger\Rebugger
StaticArrays

using IJulia
notebook() # Jupyter

using PyPlot
x = range(0,stop=5,length=101)
y = cos.(2x .+ 5)
pl = plot(x, y, linewidth=2.0, linestyle="--")
title("a nice cosinus")
xlabel("x axis")
ylabel("y axis")
gcf()


a = time()
b = time()-a
f(x) = x^2
@time 
using BenchmarkTools
@btime
@benchmark f(2)
@benchmark f(2//1)



# The LLVM
code_llvm(sqrt, (Int64,))

@code_lowered sqrt(2)
@code_warntype sqrt(2)