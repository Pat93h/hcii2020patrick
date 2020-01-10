include(joinpath("..", "src", "simulation.jl"))

test2 = simulate(config, batch_desc="newtest")
mean(degree(last(test2[2][3])))

sim = simulate(config, batch_desc="simmtest")

sim[4]

testagentset = deepcopy(sim[4][2])
for i in 1:length(testagentset)
    update_perceiv_publ_opinion!((sim[4][1], testagentset), i)
end

# Calc happiness in initial state
mean([abs(agent.opinion - agent.perceiv_publ_opinion) for agent in testagentset])

config = Config(
            network = cfg_net(
                agent_count = 1000,
                m0 = 100,
                new_follows = 10
            ),
            simulation = cfg_sim(
                ticks = 100,
                addfriends = ""
            ),
            opinion_threshs = cfg_ot(
                backfire = 0.2,
                befriend = 0.1,
                unfriend = 0.4
            ),
            agent_props = cfg_ag(
                own_opinion_weight = 0.95,
                unfriend_rate = 0.05,
                min_friends_count = 5
            )
        )



[minimum(degree(graph)) for graph in test[2][3]]

config = Config()

graph = barabasi_albert(
                config.network.agent_count,
                config.network.m0)

using Plots

histogram(degree(test[2][3][10]))

[agent for agent in test[3][2] if agent.active]

using CSV
using GraphIO
convert_results(specificrun="simtest.jld2")
