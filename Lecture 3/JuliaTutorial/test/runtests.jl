using JuliaTutorial, Test

@testset "Order tests" begin
    @test Order0(4.0)(rand()) == 4.0
    @test Order1(1//1, 2)(3) == 7
    @test Order2(3, 4, 5)(10) == 3 + 40 + 500

    @test_broken Order0(4.0)(rand()) == 3.0
end

@testset "cubic solution tests" begin
    @test typeof(solve_cubic(1,2,3,4)) <: Array{<:Number, 1}
    @test any(isapprox.(solve_cubic(0, 1, -4, 4), 0.5))
    @test any(isapprox.(solve_cubic(0, 1, 4, 4), -0.5))
end


# @inferred Order1(1, 1)



# @btime nth_derivative(0)($myparabola)(3)
# @btime nth_derivative(2)($myparabola)(3)
# @btime nth_derivative(4)($myparabola)(3)
# @btime nth_derivative(8)($myparabola)(3)


# @btime nth_generated(0)($myparabola)(3)
# @btime nth_generated(4)($myparabola)(3)
# @btime nth_generated(8)($myparabola)(3)
