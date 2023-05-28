#############################
# Variables
#############################

a = 1
typeof(a)
bitstring(a)
a = 1.0
typeof(a)
bitstring(a)
isa(a,Float64)
a = 1//1
typeof(a)
iseven(2)
isodd(2)
ispow2(4)
isfinite(a)
isinf(a)
isnan(a)
eltype(a) # types of an interated list

typemax(Int64)
typemin(Int64)
typemin(Float64)    # returns -Inf (just a convention)
typemax(Float64)    # returns Inf (just a convention)
eps(Float64)        # returns 2.22e-16
1.0 + eps(Float64)
precision(Float64)  # returns 53, effective number of bits in the mantissa

typeof(π)

a=1.0
a::Float64      # fixes type of a to generate type-stable code
a = "Hello"
a::Float64    # It also asserts type

a = 0x3             # unsigned integer, hexadecimal base
a = 0b11            # unsigned integer, binary base
a = 3.0             # Float64
a = 4 + 3im     # imaginary
a = complex(4,3)    # same as above
a = true            # boolean
a = "String"    # string
const aa = 1  # constant

# type promotion system

a = Any[1 2 3; 4 5 6]
convert(Array{Float64}, a)
Array{Float64}(a)
promote(1, 1.0) # promotes both variables to common type (here: 1.0, 1.0)

# Union types
Union{Int, String}

# arbitrary precision arithmetic with GNU Multiple Precision Arithmetic Library (GMP) and the GNU MPFR Library

BigFloat(2.1) # 2.1 here is a Float64
BigFloat("2.1") # the closest BigFloat to 2.1
BigFloat("2.1", RoundUp)
BigFloat("2.1", RoundUp, precision=128)

supertype(Float64)  # supertype of Float64
subtypes(Integer)       # subtypes of Integer

a = 1 // 2              # note // operator instead of /
b = 3//7
c = a+b
numerator(c)            # finds numerator of c
denominator(c)      # finds denominator of c

a = 1 // 0
a = 0 // 0

a = [1, 2, 3]   # vector
a = [1; 2; 3]   # same vector

first(a)        # returns 1
last(a)         # returns 3

findfirst(a.==2)
findlast(a.==2)

a  = 1:0.5:4
typeof(a)
a[2]
a  = collect(1.0:0.5:4) # vector from 1.0 to 4.0 with step 0.5
a[2]

b = [1 2 3]     # 1x3 matrix (i.e., row "vector")
b = [1 2 3]'    # 3x1 matrix (i.e., column "vector")

[1 2 3]' != [1, 2, 3]



a[2,2]      # access element 2,2
a[1,:]      # access first row
a[:,1]      # access first column
a = zeros(2,2)  # zero matrix
a = ones(2,2)     # unitary matrix
using LinearAlgebra
a = 1.0*Matrix(I,2,2)   # identity matrix
a = diagm(0 => [2,2,3]) # diagonal matrix, identity matrix
a = diagm(1 => [1,2,3]) # diagonal matrix, identity matrix
a = fill(2,3,4) # fill a 3x4 matrix with 2's
a = trues(2,2)  # 2x2 matrix of trues
a = falses(2,2) # 2x2 matrix of falses
a = rand(2,2)   # random matrix (uniform)
a = randn(2,2)  # random matrix (gaussian)

a = Array{Float64,2}
a = ["Economics" 2;
    3.1     true]

ndims(a)    # number of dimensions of a
size(a)     # size of each dimension of a
length(a)   # length (factor of the sizes) of a

a = [1 2; 3 4]  # create a 2x2 matrix
a'          # complex conjugate transpose of a
a[:]        # convert matrix a to vector
vec(a)  # vectorization of a
b  = [1 2]'
a*b         # multiplication of two matrices
a\b         # solution of linear system ax = b

inv(a)          # inverse of a
pinv(a)         # pseudo-inverse of a
rank(a)         # rank of a
norm(a)         # Euclidean norm of a
det(a)          # determinant of a
diag(a)         # diagonal of a
eigvals(a)  # eigenvalues
eigvecs(a)  # eigenvectors
tril(a)         # lower triangular matrix of a
triu(a)         # upper triangular matrix of a

show(a)     # shows a
sum(a)      # sum of a
maximum(a)  # max of a
minimum(a)  # min of a
b = [1 2;3 4]
dot(a, b)   # inner product of two vectors
a[end]      # gets last element of a
a[end-1]    # gets element of a -1

##############################
# Sparse Matrices

using SparseArrays

a = sparse([1, 2, 3], [1, 2, 3], [0, 2, 0])

a = spzeros(3)

# Passing by sharing (not by value)!!!!!!!
# Somewhat imprecissely, passing by reference

a = ["My string" 2; 3.1 true]
b = a
b[1,1]
a[1,1] = "Example of passing by sharing"
b[1,1]

pointer_from_objref(a)
pointer_from_objref(b)

b == a
b === a

# If you want passing by value
a = ["My string" 2; 3.1 true]
b = copy(a) # shallow copy

b == a
b === a
a[1,1] = "Example of passing by value"
b[1,1]


# also, a deep copy
b = deepcopy(a)

# Julia deals very well with sets
a = [1,2,3]
2 in a      # returns true
in(2,a)     # same as above
4 in a      # returns false

a = [2,1,3]
b = [2,4,5]
union(a,b)  # returns 2,1,3,4,5
intersect(a,b)  # returns 2
setdiff(a,b)    # returns 1,3
setdiff(b,a)    # returns 4,5

# Also, tuples are important

a = ("This is a tuple", 2018)   # definition of a tuple
a[2]                # accessing element 2 of tuple a
a = [1 2]
b = [3 4]
c = zip(a,b)
first(c)

#= Tuple vs. Array{Any} vs. Structs

    1. Tuples are immutable and indexed by their types
    2. Structs belong in the type system
=#