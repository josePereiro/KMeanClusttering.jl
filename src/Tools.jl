function rtuples(T::Type{<:Number}, D::Int, k::Int)::Vector{NTuple{D,T}}
    return [tuple(rand(T,D)...) for i in 1:k];
end
function rarrays(T::Type{<:Number}, D::Int, k::Int)::Vector{Vector{T}}
    return [rand(T,D) for i in 1:k];
end
function totuples(data)
    return [tuple(e...) for e in data];
end
function get_perfect_data(; n = 100)
    cs = [(-5,-5),(0,5),(5,-5)]
    dt = Vector{Tuple{Float64,Float64}}();
    xr = randn(n);
    yr = randn(n);
    for rd in 1:n
        for c in cs
            push!(dt, (xr[rd] + c[1], yr[rd] + c[2]))
        end
    end
    return dt;
end
function center_coords(ps)
    s = ps[1];
    for i in 2:length(ps)
         s = s .+ ps[i]
    end
    return s ./ length(ps);
end
function assign(p::T, cs::Vector{T}) where T
    findmin(distance(p,cs))[2];
end
function assign(ps::Vector{T}, cs::Vector{T}) where T
    return [findmin(distance(p,cs))[2] for p in ps];
end
function distance(p1, p2)
    return sqrt(sum((p1 .- p2).^2))
end
function distance(p1::T, ps::Vector{T}) where T
    return [distance(p1,p) for p in ps];
end
function ave_distance(p, ps)
    length(ps) == 0 && return zero(eltype(p))
    ds = distance(p,ps)
    return sum(ds)/length(ps);
end
function generate_test_2d_data(k; r = 35, n = 1000)
    cs = [(rand()*r,rand()*r) for i in 1:k];
    dt = Vector{Tuple{Float64,Float64}}();
    xr = randn(n);
    yr = randn(n);
    for rd in 1:n
        for c in cs
            push!(dt, (xr[rd] + c[1], yr[rd] + c[2]))
        end
    end
    return dt;
end
export fake_data
function fake_data()
    return get_perfect_data();
end
function remove(col::Vector, td)
    col[[1:(td-1);(td+1):end]];
end
function remove!(col::Vector, td)
    temp = remove(col,td);
    pop!(col);
    col .= temp;
    return col;
end
