#############################
# Basic functions
#############################

# polymorphic multiple dispatch

methods(+)

a = 1.2
abs(a)      # absolute value of a
abs2(a)     # square of a
sqrt(a)     # square root of a
isqrt(a)    # integer square root of a
cbrt(a)     # cube root of a

exp(a)      # exponent of a
exp2(a)     # power a of 2
exp10(a)    # power a of 10
expm1(a)    # exponent e^a-1 (accurate)
ldexp(a,n)  # a*(2^n)
log(a)      # log of a
log2(a)     # log 2 of a
log10(a)    # decimal log of a
log(n,a)    # log base n of a
log1p(a)    # log of 1+a (accurate)

# Some syntaxic sugar
isapprox(1.0, 1.1; atol = 0.1)

+ - * / ^   # arithmetic operations
+. -. *. /. ^.  # element-by-element operations (for vectors and matrices)
//      # division for rationals that produces another rational
+a      # identity operator
-a      # negative of a
a+=1        # a = a+1, can be applied to any operator
a\b     # back division

x = 3
7*x     # this delivers 21
7x  # this also delivers 21
x7  # this delivers an error message (Julia searches for variable "x7")

eval(a)     # evaluates expression a in a global scope
real(a)     # real part of a
imag(a)     # imaginary part of a
reim(a)     # real and imaginary part of a (a tuple)
conj(a)     # complex conjugate of a
angle(a)    # phase angle of a in radians
cis(a)      # exp(i*a)
sign(a)     # sign of a
round(a)    # rounding a to closest floating point natural
ceil(a)     # round up
floor(a)    # round down
trunc(a)    # truncate toward zero
clamp(a,low,high) # returns a clamped to [a,b]
mod2pi(a)   # module after division by 2\pi
modf(a)     # tuple with the fractional and integral part of a
div(a,b)    # same as above
cld(a,b)    # ceiling division
fld(a,b)    # flooring division
rem(a,b)    # remainder of a/b
gcd(a,b)    # greatest positive common denominator of a,b
gcdx(a,b)   # gcd of a and and and their minimal Bezout coefficients
mod(a,b)    # module a,b
mod1(a,b)   # module a,b after flooring division
lcm(a,b)    # least common multiple of a,b
min(a,b)    # min of a and (can take as many arguments as desired)
max(a,b)    # max of a and (can take as many arguments as desired)
minmax(a,b) # min and max of a and b (a tuple return)
muladd(a,b,c)   # a*b+c
+(a,b)

a = true
b = false
c = 1.0
a+c # this delivers 2.0
b+c # this delivers 1.0
a*c # this delivers 1.0
b*c # this delivers 0.0

!   # not
&&  # and
||  # or
==  # is equal?
!== # is not equal?
===     # is equal? (enforcing type 2===2.0 is false)
!===    # is not equal? (enforcing type)
>   # bigger than
>=  # bigger or equal than
<   # less than
<=  # less or equal than

3 > 2 && 4<=8 || 7 < 7.1

~   # bitwise not
&   # bitwise and
|   # bitwise or
xor # bitwise xor (also typed by \xor or \veebar + tab)
>>  # right bit shift operator
<<  # left bit shift operator
>>> # unsigned right bit shift operator

#############################
# Functions
#############################

# functions are first-class citizens
a = [exp, abs]
a[1](3)

# operators are functions
1+2
+(1,2)

# all arguments to functions are passed by sharing
# sort vs. sort!
a = [2, 1, 3]
sort(a)
sort!(a)

# One-line
foo(var) = var + 1
bar = (var) -> var + 2

function baralt(var)
    return var + 2
end

fooalt = function (var)
    var + 1
end

# passing functions (also by sharing!!!!!!!!!)
foo1 = foo
multiplication  = *

# multiple dispatch
methods(foo)
foo(var1,var2) = var1+var2+1
methods(foo)

bar(x) = println("This is for a single generic argument")
bar(x::Int) = println("This is for a single integer argument")
methods(bar)
bar(x::Number) = println("This is for a single number argument")
bar(x::Int, y::Int) = println("This is for two integer types")

bar("a")
bar(2)
bar(2//1)
bar(1, 2)

f(x, y) = x + y
f(x::Float64, y::Float64) = x^2 + y^2
f(x::Int64, y::Float64) = x - y
foobar(x::Int, y = 1) = x + y


barbar(x::Int, y::Rational) = x + y
barbar(x::Int, y) = x + y


# multiple dispatch
abstract type Shape end
abstract type AbstractRectangle <: Shape end
# subtypes of AbstractRectangle should provide `height` and `width` methods
struct Rectangle <: AbstractRectangle
    width::Float64
    height::Float64
end
width(r::Rectangle) = r.width
height(r::Rectangle) = r.height

struct Square <: AbstractRectangle
    length::Float64
end
width(s::Square) = s.length
height(s::Square) = width(s)

struct Circle <: Shape
    radius::Float64
end
area(c::Circle) = π*c.radius^2

# multiple dispatch uses the appropriate definition based on _all_ input types
area(shape::AbstractRectangle) = width(shape)*height(shape)
area(Rectangle(3, 4))
area(Square(3))
area(Circle(3))




# Broadcasting
a = [1, 2, 3]
foo.(a)

# Several lines, also show multiple dispatch
function foo15(var1, var2::Float64, var3=1)
    output1 = var1+2
    output2 = var2+4
    output3 = var3+3 # var3 is optional, by default var3=1
    return output1, output2, output3
end

# empty argument
function foo()
    output1 = 1
end

# keywords (no dispatch on kw)
function zee(var1, var2; keyword=2)
    output1 = var1+var2+keyword
end

# fixing types
function foo3(var1::Int64, var2; keyword=2)
    output1 = var1+var2+keyword
end
foo3(2.0,2)
foo3(2,2)

function foo4(x,y)::Int8
    return x*y
end
foo4(1.2,1.3)
foo4(1,1)

# Higher-order
function foo2(var1)
    function foo3(var2)
        answer  = var1+var2
        return answer
    end
    return foo3
end
foo2 = foo(1)   # creates a function foo2 that produces 1+var2
foo5 = foo(2)   # creates a function foo3 that produces 2+var2

x -> x^2            # anonymous function
a = x -> x^2    # named anonymous function
a(3)
a = x -> x.^2   # named anonymous function
a([3.0,2.0])

code_llvm(x ->x^2, (Float64,))
code_native(x ->x^2, (Float64,))

# recursion
function outer(a)
    b = a+2
    function inner(b)
        b = b+3
    end
    inner(b)
end

fib(n) = n < 2 ? n : fib(n-1) + fib(n-2)

# Closure
function counter()
    n = 0
    return () -> n = n + 1
end
# we name it
addOne = counter()
addOne()    # Produces 1
addOne()    # Produces 2

# Currying: transforms the evaluation of a function with multiple arguments into the evaluation of a sequence of functions, each with a single argument
# Haskell Curry

function mult(a)
    return function f(b)
        return a*b
    end
end
foo5 = mult(3)
foo5(9)

map(floor,[1.2, 5.6, 2.3])  # applies floor to vector [1.2, 5.6, 2.3]
map(x ->x^2,[1.2, 5.6, 2.3]) # applies abstract to vector [1.2, 5.6, 2.3]

reduce(+,[1,2,3])   # generic reduce

foldl(-,[1,2,3])    # folding (reduce) from the left
foldr(-,[1,2,3])    # folding (reduce) from the right

mapreduce(x->x^2, +, [1,3])

a = [1,5,8,10,12]
@btime filter(isodd,a) # select elements of a that are odd
@btime a[isodd.(a)]

#############################
# Macros
#############################

macro welcome(name)
    return :(println("Hello, ", $name, "!"))
end
@welcome "Lukas"
