function debug(N::Int)
    s = Vector{Float64}(undef, N)
    for n = 1:N
        s[n] = rand()
    end
    S::String = sum(s) 
    return S/N
end

@enter debug(100)