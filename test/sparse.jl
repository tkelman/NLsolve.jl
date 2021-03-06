# Test sparse Jacobian implementation (even though the Jacobian of the function
# is actually not sparse...)

function f!(x, fvec)
    fvec[1] = (x[1]+3)*(x[2]^3-7)+18
    fvec[2] = sin(x[2]*exp(x[1])-1)
end

function g!(x, fjac)
    fjac[1, 1] = x[2]^3-7
    fjac[1, 2] = 3*x[2]^2*(x[1]+3)
    u = exp(x[1])*cos(x[2]*exp(x[1])-1)
    fjac[2, 1] = x[2]*u
    fjac[2, 2] = u
end

df = DifferentiableSparseMultivariateFunction(f!, g!)

# Test trust region
r = nlsolve(df, [ -0.5; 1.4], method = :trust_region, autoscale = true)
@assert converged(r)
@assert norm(r.zero - [ 0; 1]) < 1e-8

# Test Newton
r = nlsolve(df, [ -0.5; 1.4], method = :newton, linesearch! = Optim.backtracking_linesearch!, ftol = 1e-6)
@assert converged(r)
@assert norm(r.zero - [ 0; 1]) < 1e-6

# Test MCP solver with smooth reformulation
r = mcpsolve(df, [-Inf;-Inf], [Inf; Inf], [-0.5; 1.4], reformulation = :smooth)
@assert converged(r)
@assert norm(r.zero - [ 0; 1]) < 1e-8

# Test MCP solver with minmax reformulation
r = mcpsolve(df, [-Inf;-Inf], [Inf; Inf], [-0.5; 1.4], reformulation = :minmax)
@assert converged(r)
@assert norm(r.zero - [ 0; 1]) < 1e-8
