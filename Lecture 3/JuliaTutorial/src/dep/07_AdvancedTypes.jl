#############################
# Type hierarchy and function compositions

#=
Note: One particularly distinctive feature of Julia’s type system is that concrete types may not subtype each other:
all concrete types are final and may only have abstract types as their supertypes.
=#

abstract type Equation end
abstract type Polynomial <: Equation end

struct Order0{T <: Real} <: Polynomial
    a0::T
end
(eq::Order0)(x) = eq.a0

struct Order1{T0, T1} <: Polynomial
    a0::T0
    a1::T1
    function Order1(a0::T0, a1::T1) where {T0 <: Real, T1 <: Real}
        if a1 == 0
            return Order0(a0)
        else
            return new{T0, T1}(a0, a1)
        end
    end
end
(eq::Order1)(x) = eq.a0 + eq.a1*x

aa = Order1(2, 1.0)          # an instance of Order1
bb = Order1(2.0, 0)          # this is now an instance of Order0 (because a1 == 0)

aa(3) == 5

struct Order2{T0, T1, T2} <: Polynomial
    a0::T0
    a1::T1
    a2::T2
    function Order2(a0::T0, a1::T1, a2::T2) where {T0 <: Real, T1 <: Real, T2 <: Real}
        if a2 == 0
            return Order1(a0, a1)
        else
            return new{T0, T1, T2}(a0, a1, a2)
        end
    end
end
(eq::Order2)(x) = eq.a0 + eq.a1*x + eq.a2*x^2

# Note: the constructors will not be type stable (it depends on the VALUE of a1, not on its type), but it will not matter
@code_warntype Order1(1, 1)

myparabola = Order2(1, 2, 3) # the function x -> 3x^2 + 2x + 1, with derivative 6x + 2
iden = Order2(0, 1, 0) # same as Order1(0, 1)

export myparabola

mynewfunction(x) = x
export mynewfunction

# Now it becomes interesting
derivative(eq::Order2) = Order1(eq.a1, 2*eq.a2)
derivative(eq::Order1) = Order0(eq.a1)
derivative(eq::Order0) = Order0(0)

derivative(myparabola)
derivative(derivative(myparabola))

# Function composition
secondderivative = derivative ∘ derivative
secondderivative(myparabola)

# Piping
myparabola |> derivative |> derivative

derivative(myparabola)(3)
secondderivative(myparabola)(3)

function nth_derivative(n::Integer)
    if n == 0
        return (x) -> x
    else
        return nth_derivative(n - 1) ∘ derivative
    end
end

nth_derivative(0)(myparabola)(3)
nth_derivative(1)(myparabola)(3//1)
nth_derivative(2)(myparabola)(3)
nth_derivative(3)(myparabola)(3)


@code_warntype nth_derivative(2)(myparabola)(3) # as we said, it didn't matter

# Type-instability WOULD matter here instead 
# (to check that it does replace the Order0 definition above with the following definition)
#= 
struct Order0{T} <: Polynomial
    a0::T
    f::Function
    Order0(a0::T) where {T <: Real} = new{T}(a0, (x) -> a0)
end
(eq::Order0)(x) = eq.f(x)

@code_warntype nth_derivative(2)(myparabola)(3)
=#


#############################
# Advanced topics

# Type stability is not all that matters, recursion usually badly scales up

@generated function nth_generated(::Val{n}) where {n}
    if n == 0
        return (x) -> x
    else
        return nth_generated(Val(n - 1)) ∘ derivative 
    end
end
nth_generated(n::Integer) = nth_generated(Val(n))

@btime nth_generated(0)($myparabola)(3)
@btime nth_generated(4)($myparabola)(3)
@btime nth_generated(8)($myparabola)(3)
# Could have done this using metaprogramming