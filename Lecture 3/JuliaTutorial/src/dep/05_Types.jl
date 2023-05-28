################################################################################
# Types (basics)
################################################################################

# Define a new concrete type
struct NewType end
N = NewType() # an instance of a concrete type
isconcretetype(NewType)
isconcretetype(Number)

# Define a new concrete subtype of number
struct NewNumber <: Number end

# Define a composite type
struct Dual <: Number
    value::Float64
    deriv::Float64
end

# Outer constructor
struct Point
    x::Float64
    y::Float64
end
Point(x) = Point(x, x)

# Inner constructor
struct SymmetricPoint
    x::Float64
    y::Float64
    function SymmetricPoint(x, y)
        if x != y
            error("Point is not symmetric")
        else
            new(x, y)
        end
    end
end
struct NewSymmetricPoint
    x::Float64
    y::Float64
    function NewSymmetricPoint(x)
        new(x, x)
    end
end



x = Dual(3, 4) # uses automatic conversion (promotion)
y = Dual(5, 6)

x + y # error
add(x::Dual, y::Dual) = Dual(x.value + y.value, x.deriv + y.deriv)
add(x, y)

import Base: +, *

+(x::Dual, y::Dual) = add(x, y)
*(x::Dual, y::Dual) = Dual(x.value * y.value, x.value * y.deriv + x.deriv * y.value)

# We now have enough to be able to differentiate simple Julia functions involving only + and *

a = 3.0
xx = Dual(a, 1.0) # the identity function x -> x, with derivative 1

ff(x) = x * x * x + x * x + x * x # x^3 + 2x^2
ff(a)
dff(x) = 3x^2 + 4x
dff(a)

ff(xx)

#############################
# parametric types
struct ParPoint{T}
    x::T
    y::T
end
Point(1, 3) # T is inferred as `Int64`
Point(1, 3.0) # errors because all cases of T must be of the same concrete type

##############################
# More on parametric types, method extensions and type conversion/promotion

struct Const{T<:Real}
    a0::T   # We parameterize Order0 by the type of a0
end
(eq::Const)(x) = eq.a0     # Make every instance of type Order0 callable

# Parametric types:
a = Const(1)               # an instance of type Order0{Int64}
typeof(a)
b = Const(1.0)
typeof(b)                   # an instance of type Order0{Float64}
typeof(a) != typeof(b)      # a and b are both of type Order0 but they are not of the same type
typeof(a) <: Const         # Order0{Int64} is both of type Order0 and a subtype of Order0
supertype(typeof(a))        # Order0{Int64} is a direct subtype of Polynomial

c = Const(4 + 3im)         # Error: cannot create a instance of Order0{Complex} because we restricted T to be a subtype of real

a(rand()) == 1


#############################
# Type stability and parametric types

# Type stability
a = 2
function unstable(x)
    return a * x
end
function stable(x)
    b = 2
    return b * x
end

@code_warntype stable(2)
@code_warntype unstable(2)

@benchmark stable(2)
@benchmark unstable(2)

@code_llvm stable(2)
@code_llvm unstable(2)


# Type stable (but non-generic)
struct StrictAffine
    a::Float64
    b::Float64
end

(l::StrictAffine)(x::Float64) = l.a * x + l.b # type restriction on the function is non-necessary
iden = StrictAffine(1.0, 0.0)
iden(3.0) # returns 3.0
@code_warntype iden(3.0)

# Generic (but type-instable)
struct GenericAffine
    a
    b
end
(l::GenericAffine)(x) = l.a * x + l.b
gen_iden = GenericAffine(1.0, 0.0)
gen_iden(3.0)
@code_warntype gen_iden(3.0)


struct RealAffine
    a::Real
    b::Real
end

(l::RealAffine)(x) = l.a * x + l.b
real_iden = RealAffine(1.0, 0.0)
real_iden(3.0)
@code_warntype real_iden(3.0)

# Generic and type stable
struct ParametricAffine{T1,T2}
    a::T1
    b::T2
end

(l::ParametricAffine)(x) = l.a * x + l.b
par_iden = ParametricAffine(1.0, 0.0)
par_iden(3.0)
@code_warntype par_iden(3.0)

# However, you might want to restrict the parameters
par_wrong = ParametricAffine("hello", 0)
par_wrong(3)

# Can also restrict type parameters (even better)
struct ParametricRealAffine{T1<:Real,T2<:Real}
    a::T1
    b::T2
end

(l::ParametricRealAffine)(x) = l.a * x + l.b
parreal_iden = ParametricRealAffine(1 // 1, 0)
parreal_iden(3.0)
@code_warntype parreal_iden(3)

ParametricRealAffine("a", 0) # gives error

parreal_iden = ParametricRealAffine(1.0, 0.0)

using BenchmarkTools
@btime iden(3.0)
@btime gen_iden(3.0)
@btime real_iden(3.0)
@btime par_iden(3.0)
@btime parreal_iden(3.0)



#############################
# More

struct ParDual{T1<:Real,T2<:Real} <: Number
    v::T1
    d::T2
end

import Base: +, *
+(x::Number, y::ParDual) = ParDual(x + y.v, y.d)
+(y::ParDual, x::Number) = +(x, y)
+(x::ParDual, y::ParDual) = ParDual(x.v + y.v, x.d + y.d)

*(x::Number, y::ParDual) = ParDual(x * y.v, x * y.d)
*(y::ParDual, x::Number) = *(x, y)
*(x::ParDual, y::ParDual) = ParDual(x.v * y.v, x.v * y.d + x.d * y.v)

xx = ParDual(3, 1)
yy = ParDual(4, 3.0)
2 + xx
3.3 + xx + yy
xx * yy + 0.5 + 2 * xx


# Here we define a new method to convert any (real) number into a dual number
convert(::Type{ParDual}, x::T) where {T<:Real} = ParDual{T,Int}(x, 0)
convert(ParDual, 2)
convert(ParDual, 3.4)
convert(ParDual, 7 // 2)



################################################################################
# Types (constructors and methods) and Named Tuples
################################################################################

struct MicroSurveyObservation
    id::Int64
    year::Int64
    quarter::Int64
    region::String
    ageHouseholdHead::Int64
    familySize::Int64
    numberChildrenunder18::Int64
    consumption::Float64
end

household1 = MicroSurveyObservation(12, 2017, 3, "angushire", 23, 2, 0, 345.34)

fieldnames(MicroSurveyObservation)

household1.familySize
totalPopulation = household1.familySize
household1.id = 31 # it will give you an error

# Mutable
mutable struct MutableMicroSurveyObservation
    id::Int64
    year::Int64
    quarter::Int64
    region::String
    ageHouseholdHead::Int64
    familySize::Int64
    numberChildrenunder18::Int64
    consumption::Float64
end

household1 = MutableMicroSurveyObservation(12, 2017, 3, "angushire", 23, 2, 0, 345.34)
household1.id = 31

function EquivalenceScale(x::MicroSurveyObservation)
    if x.familySize == 1
        return x.consumption
    else
        return x.consumption / (1 + 0.5 * (x.familySize - 1))
    end
end

household1 = MicroSurveyObservation(12, 2017, 3, "angushire", 23, 2, 0, 345.34)
EquivalenceScale(household1)

function AverageConsumption(x::MicroSurveyObservation, y::MicroSurveyObservation)
    return 0.5 * (x.consumption + y.consumption)
end

import Base: +
+(x::MicroSurveyObservation, y::MicroSurveyObservation) = x.consumption + y.consumption

household1 = MicroSurveyObservation(12, 2017, 3, "angushire", 23, 2, 0, 345.34)
household2 = MicroSurveyObservation(13, 2015, 2, "Wolpex", 35, 5, 2, 645.34)

household = Vector{MicroSurveyObservation}(undef, 10)
household[1] = MicroSurveyObservation(12, 2017, 3, "angushire", 23, 2, 0, 345.34)
household[2] = MicroSurveyObservation(13, 2015, 2, "Wolpex", 35, 5, 2, 645.34)

for i in 1:10
    # read file with observation
    household[i] = MicroSurveyObservation()#=data from previous step=#
end

household1 = (id=12,
    year=2017,
    quarter=3,
    region="angushire",
    ageHouseholdHead=23,
    familySize=2,
    numberChildrenunder18=0,
    consumption=345.34)

using DataFrames, Statistics
microSurveyObservations = DataFrame(; household1...) #Creating with named tuple
household2 = (id=15,
    year=2017,
    quarter=3,
    region="angushire",
    ageHouseholdHead=26,
    familySize=2,
    numberChildrenunder18=0,
    consumption=1345.34)
push!(microSurveyObservations, household2) #Push named tuples onto the dataframe
mean(microSurveyObservations[:consumption]) #Statistics.


################################################################################
# Dictionaries
################################################################################

# Creating a dictionary
a = Dict("University of Pennsylvania" => "Philadelphia", "Boston College" => "Boston")
a["University of Pennsylvania"]     # access one key
a["Harvard"] = "Cambridge"  # adds an additional key
delete!(a, "Harvard")    # deletes a key
keys(a)
values(a)
haskey(a, "University of Pennsylvania")  # returns true
haskey(a, "MIT") # returns false