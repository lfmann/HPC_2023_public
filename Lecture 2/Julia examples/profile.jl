function profile_test(n)
    for i = 1:n
        A = randn(1000, 1000, 200)
        m = maximum(A)
        Am = mapslices(sum, A; dims = 2)
        B = A[:, :, 5]
        Bsort = mapslices(sort, B; dims = 1)
        b = rand(1000)
        C = B.*b
    end
end

#Run once for compilation (ignore)
@profview profile_test(1)
#Get profiler output:
@profview profile_test(10)