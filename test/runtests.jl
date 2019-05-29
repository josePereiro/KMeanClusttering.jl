using KMeanClusttering;
using Test;
@testset "KMeanClusttering.jl" begin

    for k in 3:10
        dt = KMeanClusttering.generate_test_2d_data(k);
        km = KMeanClusttering.KModel(k,dt);
        printstyled("Runing test k = $k\n", color = :green);
        println("Before K-Mean")
        bd = KMeanClusttering.ave_distance(km);
        println("Ave distance $(bd)");
        println("After K-Mean")
        km = KMeanClusttering.find_clusters(k,km.data);
        km = KMeanClusttering.get_clean(km);
        ad = KMeanClusttering.ave_distance(km);
        println("Ave distance $(ad)");
        println();
        @test bd > ad;
    end

    printstyled("""For a graphic view run the jupyter notebook "Example.ipynb",
    located in the root folder of the package.""", color = :green);
    println();
    println();

end
