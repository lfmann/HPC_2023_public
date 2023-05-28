# Function to solve a cubic equation of the form ax^3+bx^2+cx+d=0
function solve_cubic(d::Real, c::Real, b::Real, a::Real)

    ζ  = complex(-0.5, sqrt(3)/2)
    ζ² = conj(ζ)

    a₁ = 1/a
    E₁ = -b*a₁
    E₂ = c*a₁
    E₃ = -d*a₁

    s₀ = E₁
    E₁² = E₁*E₁
    A = 2*E₁*E₁² - 9*E₁*E₂ + 27*E₃
    B = E₁² - 3*E₂
    A² = A*A
    Δ = sqrt(complex(A² - 4*B^3))

    if real(conj(A)*Δ) >= 0
        s₁ = (0.5*(A + Δ))^(1/3)
    else
        s₁ = (0.5*(A - Δ))^(1/3)
    end

    if s₁ == complex(0.0)
        s₂ = complex(0.0)
    else
        s₂ = B/s₁
    end

    x₀ = (s₀ + s₁ + s₂)/3
    x₁ = (s₀ + s₁*ζ² + s₂*ζ)/3
    x₂ = (s₀ + s₁*ζ + s₂*ζ²)/3

    res = [x₀; x₁; x₂]
    
    return res
end

export solve_cubic