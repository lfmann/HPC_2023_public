#############################
# Control structures
#############################

# Conditionals

x = 1
y = 1

if x < y
    println("x is less than y")
elseif x > y
    println("x is greater than y")
else
    println("x is equal to y")
end

x < y ? println("x is less than y") : println("x is not less than y")

# Lazy evaluation
x < y && println("x is smaller than y")
x > y || println("x is not greater than y")

x = 1
typeof(x) <: String || error("Not a string")

x <= y && z = x
x <= y && (z = x)

if x <= y
    z = x
end

a = x < y ? x : y   # correct
a = x < y && x      # wrong

# Loops

for i in 1:5
    println(i)
end

for i in 1:0.1:5
    println(i)
end

a = [1, 2, 4]
for i in a
    println(i)
end

for i in eachindex(a)
    println(i)
end

for (i,a_i) in enumerate(a)
    println("i=$i, a_i=$a_i")
end

for i ∈ 1:5
    println(i)
end

for i = 1:5
    println(i)
end

for i = 1:2
    for j = 3:4
        println((i, j))
    end
end


for i = 1:2, j = 3:4
    println((i, j))
end

for i = 1:2, j = 3:4
    println((i, j))
    if i > 1 
        break
    end
end

for i = 1:2, j = 3:4
    if i == 1 
        continue 
    end
    println((i, j))
end


# Julia is column dominant
function slow(n)
    A = Matrix{Float64}(undef, n, n)
    for i = 1:n, j = 1:n
        A[i, j] = rand()
    end
return A
end
function fast(n)
    A = Matrix{Float64}(undef, n, n)
    for i = 1:n, j = 1:n
        A[j, i] = rand()
    end
    return A
end

@btime slow(10000);
@btime fast(10000);

function fast2(n)
    A = Matrix{Float64}(undef, n, n)
    for idx in CartesianIndices(A)
        (r, c) = Tuple(idx)
        println("r = ", r, "; c = ", c)
        A[r, c] = rand()
        # A[idx] = rand()
    end
    return A
end

function fast3(n)
    A = Matrix{Float64}(undef, n, n)
    for idx in eachindex(A)
        A[idx] = rand()
    end
    return A
end


# Comprenhensions
[n^2 for n in 1:5]      # basic comprehensions
Float64[n^2 for n in 1:5]   # comprehension fixing type
[x+y+z-a^2 for x in 1:3, y = 1:4, z=1:4, a=1:3]

# Generators
sum(1/n^2 for n = 1:1000)

slow(n) = sum([1/i^2 for i = 1:n])
fast(n) = sum(1/i^2 for i = 1:n)

@btime fast(1_000_000);
@btime slow(1_000_000);

i = 0
while i <= 5
    println(i)
    i += 1
end
