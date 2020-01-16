include(joinpath("..", "src", "simulation.jl"))

test2 = simulate(config, batch_desc="bigbarabasidigraph")

Simulation()

testing = run!(Simulation(Config(network=cfg_net(agent_count = 100, m0=10), simulation = cfg_sim(ticks=100))))

graph = deepcopy(testing.init_state[1])
histogram(indegree(last(test2[2][3])))

friend_candidates = Int64[]

for neighbor in neighbors(graph, 1)
    append!(
        friend_candidates,
        setdiff(
            neighbors(graph, neighbor),
            neighbors(graph, 1),
            1
        )
    )

end

setdiff(collect(1:10), collect(2:4), 5)
push!(neighbors(graph, 1), 1)

friend_candidates

for i in 1:9
    specificrun = "BA_run0" * string(i) *".jld2"
    convert_results(specificrun=specificrun)
end

simulate_batch(configbatch, stop_at=9, batch_desc = "BA")

using JLD
using JLD2

multicomp = load("results\\BA_run01.jld2")
multicomp = multicomp["BA_run01"]
multicomp = multicomp[3][1]

using GraphPlot

gplot(multicomp)

community_layout(multicomp)
connected_components(multicomp)
findfirst(connected_components(multicomp), 1)
findfirst(1,connected_components(multicomp))
findfirst(connected_components(multicomp))
is_connected(multicomp)
in(1,connected_components(multicomp))

node_component = Int64[]
for node in 1:nv(multicomp), i in keys(connected_components(multicomp))
        if node in connected_components(multicomp)[i]
            push!(node_component, i)
        end

end

[i for (i, node) in (keys(connected_components(multicomp)), 1:nv(multicomp)) if node in connected_components(multicomp)[i]]
(
    [i for i in keys(connected_components(multicomp)), node in 1:nv(multicomp)
    if node in connected_components(multicomp)[i]]
)

test = 0

run!(Simulation(configbatch[1]))

test = Simulation()

run!(test)

configbatch[1]

local_clustering_coefficient(multicomp)

add_vertex!(multicomp)
connected_components(multicomp)

empty[1]

barabasi_albert(100,10)

ceil(Int, length(string(length(configbatch))))

configbatch = Config[]
for agent_count in [100, 1000, 10000], addfriends in ["", "neighborsofneighbors", "random"], unfriend in [0.4, 0.6, 0.8]
    push!(configbatch,Config(
                    network = cfg_net(
                        agent_count = agent_count,
                        m0 = 10,
                        new_follows = 10
                    ),
                    simulation = cfg_sim(
                        ticks = 100,
                        addfriends = addfriends
                    ),
                    opinion_threshs = cfg_ot(
                        backfire = 0.3,
                        befriend = 0.1,
                        unfriend = unfriend
                    ),
                    agent_props = cfg_ag(
                        own_opinion_weight = 0.95,
                        unfriend_rate = 0.05,
                        min_friends_count = 5
                    )
                )
            )
end


configbatch
i = 1
for agent_count in [100, 1000, 10000], addfriends in ["", "neighborsofneighbors", "random"], unfriend in [0.4, 0.6, 0.8]

    println("Configuration: \n
        agent_count = $agent_count \n
        addfriends = $addfriends \n
        unfriend = $unfriend \n
        ------")

end

convert_results(specificrun="BA_run25.jld2")


newgraph = SimpleDiGraph()

add_vertex!(newgraph)
add_edge!(newgraph,1,2)
setdiff(collect(1:4),collect(neighbors(newgraph,1), 3))

[collect([1,2]), 2]

push([1,2],3)
neighbor
