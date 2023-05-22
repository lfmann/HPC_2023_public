################################################################################
# Recursion

fib(i::Int) = i <= 1 ? i : fib(i - 1) + fib(i - 2)

function fib(i::Int)
    if i <= 1
        return i
    else 
        return fib(i - 1) + fib(i - 2)
    end
end


################################################################################
# Currying

function add_to(x::Number)
    f = (y) -> x + y
    return f
end

add_to(2)
add_to(2)(3)

################################################################################
# Higher-order functions

function apply(f, x)
    return f(x)
end

foo(y) = y^2
apply(foo, 3)


################################################################################
# Immutability

a = 3
function bar(x)
    a = 5
    return a + x
end

println(a)
bar(3)
println(a)


################################################################################
# Object-oriented

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

household1 = MicroSurveyObservation(12,2017,3,"angushire",23,2,0,345.34)

fieldnames(MicroSurveyObservation)

household1.familySize
totalPopulation = household1.familySize

function EquivalenceScale(x::MicroSurveyObservation)
    if x.familySize == 1
      return x.consumption
    else
      return x.consumption/(1+0.5*(x.familySize-1))
    end
end

EquivalenceScale(household1)

function AverageConsumption(x::MicroSurveyObservation,y::MicroSurveyObservation)
    return 0.5*(x.consumption+y.consumption)
end

household1 = MicroSurveyObservation(12,2017,3,"angushire",23,2,0,345.34)
household2 = MicroSurveyObservation(13,2015,2,"Wolpex",35,5,2,645.34)

household1 + household2

methods(+)

import Base: +
+(x::MicroSurveyObservation,y::MicroSurveyObservation) = x.consumption + y.consumption

methods(+)

household1 + household2
