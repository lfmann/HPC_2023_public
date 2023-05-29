#!/bin/bash
#=
    This file can be run either directly from the REPL or as a script
    When run as a script you can provide an command-line argument with the
    total number of processes you'd like the script to be run with    
=#

#--------------------------------#
#         House-keeping          #
#--------------------------------#

using Distributed
using Distributions
using Dates

#--------------------------------#
#         Initialization         #
#--------------------------------#

# Number of cores/workers
isassigned(ARGS, 1) ? n_procs = parse(Int, ARGS[1]) : n_procs = 8
addprocs(n_procs - 1)
@info "Running a julia instance with $(nprocs()) process(es)"


#--------------------------------#
#     Structure and function     #
#--------------------------------#

# Data structure of state and exogenous variables
@everywhere struct ModelStatePMap
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

# Function that computes value_pmap function, given vector of state variables
@everywhere function value_pmap(currentState::ModelStatePMap)

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


function main_pmap()

    # Grid for x
    nx            = 1500;
    xmin          = 0.1;
    xmax          = 4.0;

    # Grid for e: parameters for Tauchen
    ne            = 15;
    ssigma_eps    = 0.02058;
    llambda_eps   = 0.99;
    m             = 1.5;

    # Utility function
    ssigma        = 2;
    bbeta         = 0.97;
    T             = 10;

    # Prices
    r             = 0.07;
    w             = 5;

    # Initialize the grid for X
    xgrid = zeros(nx)

    # Initialize the grid for E and the transition probability matrix
    egrid = zeros(ne)
    P     = zeros(ne, ne)

    # Initialize value_pmap function V
    V           = zeros(T, nx, ne)
    V_tomorrow  = zeros(nx, ne)


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
    for i in 1:ne
      egrid[i] = exp(egrid[i]);
    end



    #--------------------------------#
    #     Life-cycle computation     #
    #--------------------------------#

    print(" \n")
    print("Life cycle computation: \n")
    print(" \n")

    start = Dates.unix2datetime(time())

    for age = T:-1:1

      pars = [ModelStatePMap(ind,ne,nx,T,age,P,xgrid,egrid,ssigma,bbeta, V_tomorrow,w,r) for ind in 1:ne*nx];

      s = pmap(value_pmap,pars)

      for ind = 1:nx*ne
        ix      = convert(Int, floor((ind-0.05)/ne))+1;
        ie      = convert(Int, floor(mod(ind-0.05, ne))+1);

        V[age, ix, ie] = s[ind]
        V_tomorrow[ix, ie] = s[ind]
      end

      finish = convert(Int, Dates.value(Dates.unix2datetime(time())- start))/1000;
      print("Age: ", age, ". Time: ", finish, " seconds. \n")

    end

    print("\n")
    finish = convert(Int, Dates.value(Dates.unix2datetime(time())- start))/1000;
    print("TOTAL ELAPSED TIME: ", finish, " seconds. \n")
end


println()
println("first run is for compilaton")
main_pmap()

println("now we can measure time")
main_pmap()