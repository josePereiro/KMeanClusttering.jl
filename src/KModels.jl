
export find_clusters;
export KModel;

struct KModel{D,T <: Number}
    k::Int
    dims::Int
    centroids::Vector{NTuple{D,T}}
    data::Vector{NTuple{D,T}}
    assignm::Vector{Int}

    function KModel{D,T}(centroids, data, assignm) where T <: Number where D
        @assert eltype(eltype(centroids)) == eltype(eltype(centroids)) == T
        return new(length(centroids),D,totuples(centroids),totuples(data),assignm);
    end
    function KModel{D,T}(centroids::Vector{NTuple{D,T}},
        data::Vector{NTuple{D,T}},
        assignm::Vector{Int}) where T <: Number where D
        return new(length(centroids),D,centroids,data,assignm);
    end
    function KModel{D,T}(k, data) where T <: Number where D
        data = totuples(data);
        dc = center_coords(data) .* 2;
        centroids = [dc .* c for c in rtuples(Float64,D,k)];
        new(k,D,centroids, data, assign(data,centroids))
    end
end
function KModel(k, data)
    @assert length(data) > 0
    T = eltype(eltype(data));
    D = length(first(data));
    return KModel{D,T}(k,data)
end

data(km) = km.data;
data(km,c) = km.data[findall(isequal(c),km.assignm)];
ave_distance(km) = sum([ave_distance(km,c) for c in 1:km.k])/km.k;
ave_distance(km::KModel, c) = ave_distance(km.centroids[c],data(km,c));
non_empty_centroids(km::KModel) = findall((c) -> length(data(km,c)) > 0, 1:km.k);
empty_centroids(km::KModel) = findall((c) -> length(data(km,c)) == 0, 1:km.k);
KModel(km::KModel) = KModel{km.dims,eltype(eltype(km.data))}(copy(km.centroids),copy(km.data),copy(km.assignm));

function update_kmodel!(km , tol::Float64)
    alltolr = true;
    update_assigment!(km);

    for c in 1:km.k

        cd = data(km,c);
        if length(cd) == 0
            ccoords = center_coords(km.centroids)
        else
            ccoords = center_coords(cd);
        end
        if distance(ccoords, km.centroids[c]) > tol alltolr = false; end
        km.centroids[c] = ccoords;

    end

    return alltolr;
end
update_kmodel!(km; tol::Float64 = 1e-4) = update_kmodel!(km , tol);
function update_kmodel_many_times!(km , tol, itrs)
    for i in 1:itrs
        update_kmodel!(km, tol) && return true;
        i == itrs && return false;
    end
end
update_kmodel_many_times!(km; tol = 1e-4, itrs = 100) = update_kmodel_many_times!(km , tol, itrs)
update_assigment!(km) = km.assignm .= tuple(assign(km.data, km.centroids)...);
update_k!(km) = km.k = length(km.centroids);

function find_clusters(k, data; itrs = 100, uptol = 1e-5, upitrs = 100)
    @assert length(data) > 0
    D = length(first(data));
    T = eltype(first(data))

    bestkm = KModel{D,T}(k,data);
    update_kmodel_many_times!(bestkm, uptol, upitrs);
    for i in 1:itrs
        newkm = KModel{D,T}(k,data);
        update_kmodel_many_times!(newkm, uptol, upitrs);
        if ave_distance(bestkm) > ave_distance(newkm)
            bestkm = newkm;
        end
    end
    return bestkm;
end

function get_clean(km)
    nec = non_empty_centroids(km);
    if length(nec) == 0
        return KModel(km);
    else
        cd = km.centroids[nec];
        newkm = KModel{km.dims, eltype(eltype(km.data))}(cd, copy(km.data), copy(km.assignm));
        update_assigment!(newkm);
        return newkm;
    end
end
