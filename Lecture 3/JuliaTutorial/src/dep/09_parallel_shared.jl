#!/bin/bash
#=
    This file can be run either directly from the REPL or as a script
    When run as a script you can provide an command-line argument with the
    total number of processes you'd like the script to be run with    
=#

#--------------------------------#
#         House-keeping          #
#--------------------------------#

using Pkg
Pkg.add("Distributions")
Pkg.add("Compat")

using Distributed
using Distributions
using Compat.Dates
using SharedArrays

#--------------------------------#
#         Initialization         #
#--------------------------------#

# Number of cores/workers
isassigned(ARGS, 1) ? n_procs = parse(Int, ARGS[1]) : n_procs = 1
addprocs(n_procs - 1)
@info "Running a julia instance with $(nprocs()) process(es)"

#--------------------------------#
#     Structure and function     #
#--------------------------------#

# Data structure of state and exogenous variables
@everywhere struct ModelStateShared
  ind::Int64
  ne::Int64
  nx::Int64
  T::Int64
  age::Int64
  P::Array{Float64,2}
  xgrid::Vector{Float64}
  egrid::Vector{Float64}
  ssigma::Float64
  bbeta::Float64
  V::Array{Float64,2}
  w::Float64
  r::Float64
end

@everywhere function value_shared(currentState::ModelStateShared)

  ind     = currentState.ind
  age     = currentState.age
  ne      = currentState.ne
  nx      = currentState.nx
  T       = currentState.T
  P       = currentState.P
  xgrid   = currentState.xgrid
  egrid   = currentState.egrid
  ssigma  = currentState.ssigma
  bbeta   = currentState.bbeta
  w       = currentState.w
  r       = currentState.r
  V       = currentState.V

  ix      = convert(Int, floor((ind-0.05)/ne))+1;
  ie      = convert(Int, floor(mod(ind-0.05, ne))+1);

  VV      = -10.0^3;
  ixpopt  = 0;


    for ixp = 1:nx

      expected = 0.0;
      if(age < T)
        for iep = 1:ne
          expected = expected + P[ie, iep]*V[ixp, iep];
        end
      end

      cons  = (1 + r)*xgrid[ix] + egrid[ie]*w - xgrid[ixp];

      utility = (cons^(1-ssigma))/(1-ssigma) + bbeta*expected;

      if(cons <= 0)
        utility = -10.0^(5);
      end

      if(utility >= VV)
        VV = utility;
        ixpopt = ixp;
      end

      utility = 0.0;
    end

    return(VV);

end

function main_shared()
    # Grid for x
    @everywhere nx  = 1500;
    xmin            = 0.1;
    xmax            = 4.0;

    # Grid for e: parameters for Tauchen
    @everywhere ne  = 15;
    ssigma_eps      = 0.02058;
    llambda_eps     = 0.99;
    m               = 1.5;

    # Utility function
    @everywhere ssigma   = 2;
    @everywhere bbeta    = 0.97;
    @everywhere T        = 10;

    # Prices
    @everywhere r  = 0.07;
    @everywhere w  = 5;

    # Initialize the grid for X
    @everywhere xgrid = zeros(nx)

    # Initialize the grid for E and the transition probability matrix
    @everywhere egrid = zeros(ne)
    @everywhere P     = zeros(ne, ne)

    # Initialize value_shared function V
    @everywhere V          = zeros(T, nx, ne)
    @everywhere V_tomorrow = zeros(nx, ne)

    # Initialize value_shared function as a shared array
    tempV = SharedArray{Float64}(ne*nx)

    #--------------------------------#
    #         Grid creation          #
    #--------------------------------#

    # Grid for capital (x)
    size = nx;
    xstep = (xmax - xmin) /(size - 1);
    for i = 1:nx
      xgrid[i] = xmin + (i-1)*xstep;
    end

    # Grid for productivity (e) with Tauchen (1986)
    size = ne;
    ssigma_y = sqrt((ssigma_eps^2) / (1 - (llambda_eps^2)));
    estep = 2*ssigma_y*m / (size-1);
    for i = 1:ne
      egrid[i] = (-m*sqrt((ssigma_eps^2) / (1 - (llambda_eps^2))) + (i-1)*estep);
    end

    # Transition probability matrix (P) Tauchen (1986)
    mm = egrid[2] - egrid[1];
    for j = 1:ne
      for k = 1:ne
        if(k == 1)
          P[j, k] = cdf(Normal(), (egrid[k] - llambda_eps*egrid[j] + (mm/2))/ssigma_eps);
        elseif(k == ne)
          P[j, k] = 1 - cdf(Normal(), (egrid[k] - llambda_eps*egrid[j] - (mm/2))/ssigma_eps);
        else
          P[j, k] = cdf(Normal(), (egrid[k] - llambda_eps*egrid[j] + (mm/2))/ssigma_eps) - cdf(Normal(), (egrid[k] - llambda_eps*egrid[j] - (mm/2))/ssigma_eps);
        end
      end
    end

    # Exponential of the grid e
    for i = 1:ne
      egrid[i] = exp(egrid[i]);
    end






    #--------------------------------#
    #     Life-cycle computation     #
    #--------------------------------#

    print(" \n")
    print("Life cycle computation: \n")

    start = Dates.unix2datetime(time())

    for age = T:-1:1

      @sync @distributed for ind = 1:(ne*nx)

        ix      = convert(Int, ceil(ind/ne));
        ie      = convert(Int, floor(mod(ind-0.05, ne))+1);

        currentState = ModelStateShared(ind,ne,nx,T,age,P,xgrid,egrid,ssigma,bbeta, V_tomorrow,w,r)
        tempV[ind] = value_shared(currentState);

      end

      for ind = 1:(ne*nx)

        ix      = convert(Int, ceil(ind/ne));
        ie      = convert(Int, floor(mod(ind-0.05, ne))+1);

        V[age, ix, ie] = tempV[ind]
        V_tomorrow[ix, ie] = tempV[ind]
      end

      finish = convert(Int, Dates.value(Dates.unix2datetime(time())- start))/1000;
      print("Age: ", age, ". Time: ", finish, " seconds. \n")
    end

    finish = convert(Int, Dates.value(Dates.unix2datetime(time())- start))/1000;
    println("TOTAL ELAPSED TIME: ", finish, " seconds.")
    println()
end

println()
println("first run is for compilaton")
main_shared()

println("now we can measure time")
main_shared()