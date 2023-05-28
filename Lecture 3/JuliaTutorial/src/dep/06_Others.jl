#############################
# Metaprogramming
#############################

a = quote
    "I like economics"
end
typeof(a)   # returns Expr
eval(a)

name = "Jesus"
a  = :(name*" likes economics")
eval(a) # returns "Jesus likes economics"
name = "Pablo"
eval(a) # returns "Pablo likes economics"

a  = :($name*" likes economics")

function math_expr(op, op1, op2)
    expr = Expr(:call, op, op1, op2)
    return expr
end

ex = math_expr(:+, 1, Expr(:call, :*, 4, 5))
eval(ex)

ex = math_expr(:*, 1, Expr(:call, :*, 4, 5))
eval(ex)

#############################
# Strings
#############################

string('a','b')     # returns ab
string("a","b")     # returns ab
"a"*"b"         # returns ab
" "         # white space
"a"*" "*"b"     # returns a b
*("a","b")      # returns ab
repeat("a",2)       # returns aa
"a"^2           # returns aa also
join(["a","b"]," and ") # returns "a and b"

a = 3
string("a=$a")      # returns a=3

b = true
string(b)       # returns "true"

a = 1
print(a)      # basic printing functionality, no formatting
println(a)  # as before, plus a newline
using Printf
# first an integer, second a float with two decimals, third a character
@printf("%d %.2f % c\n", 32, 34.51, 'a')
# Now a composed string
name = "Jesus"
@printf("%s likes economics \n", name)
# It will print with color
printstyled(a;color=:red)
printstyled(a;color=:magenta)
printstyled(a;color=:blue)
a = readline()
f = open("results.txt", "w") # open file "results.txt"

using CSV
CSV.read(filename)

open("results.txt", "w") do f
    write(f, "I like economics")
    close(f)
end
open("results.txt", "r") do f
    mystring = readline(f)
    close(f)
end

##############################################################
# Plots
##############################################################

using Plots
pyplot()

x = 1:10
y = x.^2
plot(x,y)

plot(x,y,title="A nicer plot", label = "Square function", xlabel = "x-axis", ylabel ="y-axis")

plot!(x,y.+1,title="A second plot", label = "Square function", xlabel = "x-axis", ylabel ="y-axis")

savefig("figure1.pdf")

using Distributed
using LinearAlgebra
M = Matrix{Float64}[rand(1000,1000) for i = 1:10];
addprocs(4)
@time pmap(svdvals, M);

using Profile
@profile main()
Profile.print(format=:flat)

##############################################################
# Style
##############################################################

struct Order2{T0,T1,T2}<:Polynomial
a0::T0
a1::T1
a2::T2
function Order2(a0::T0,a1::T1,a2::T2) where {T0<:Real,T1<:Real,T2<:Real}
if a2==0
return Order1(a0,a1)
else
return new{T0,T1,T2}(a0,a1,a2)
end
end
end

