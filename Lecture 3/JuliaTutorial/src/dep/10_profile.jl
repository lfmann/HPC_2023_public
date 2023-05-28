function profile_test(n)
    for i = 1:n
        A = randn(100, 100, 20)
        m = maximum(A)
        Am = mapslices(sum, A; dims = 2)
        B = A[:, :, 5]
        Bsort = mapslices(sort, B; dims = 1)
        b = rand(100)
        C = B.*b
    end
end

# compilation
@profview profile_test(1)
# pure runtime
@profview profile_test(10)







using BenchmarkTools

fib(i) = i <= 1 ? i : fib(i - 1) + fib(i - 2)

function fibn_inefficient(n)
    res = []
    for i = 1:n
        x = fib(i)
        push!(res, x)
    end
    return res
end

fibn_inefficient(20)

@btime fibn_inefficient(20);
@profview fibn_inefficient(30)


function fibn(n::Int)
    res = Vector{Int}(undef, n)
    for i = 1:n
        res[i] = fib(i)
    end
    return res
end

@btime fibn(20);
@profview fibn(30)