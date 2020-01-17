include(joinpath("..", "src", "simulation.jl"))


run_batch(configbatch, batch_name="BAv2")

barabasi_albert(1000, 500)


batchrun = Simulation[]
for i in 1:3
    temp = load(joinpath("results", readdir("results")[i]))
    push!(batchrun, temp[first(keys(temp))])
end


using Plots
histogram([agent.opinion for agent in batchrun[3].final_state[2]], bins = 100)

convert_results(specific_run="BAv2_run03.jld2")


readdir("results")


stop_at = 0
if stop_at == 0
    stop_at = 2
end



using JLD
using JLD2

configbatch = Config[]

for
    unfriend in [0.4, 0.8, 1.2],
    addfriends in ["", "neighborsofneighbors", "random"],
    agent_count in [100, 1000],
    m0 in [agent_count/10, agent_count/5, agent_count/2]

    push!(configbatch, Config(
            network = cfg_net(
                agent_count = agent_count,
                m0 = Int(m0),
                new_follows = 10
            ),
            simulation = cfg_sim(
                ticks = 1000,
                addfriends = addfriends
            ),
            opinion_threshs = cfg_ot(
                backfire = 0.4,
                befriend = 0.2,
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
