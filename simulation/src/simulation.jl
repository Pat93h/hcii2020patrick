using LightGraphs
using DataFrames
using Random
using Statistics
using JLD
using JLD2
using StatsBase
using CSV
using GraphIO

for script in readdir("src")
    if script != "simulation.jl"
        include(script)
    end
end

mutable struct Simulation

    config::Config
    init_state::Any
    final_state::Any
    agent_log::DataFrame
    post_log::Any
    graph_list::Array{AbstractGraph}

    function Simulation(config=Config())
        new(
            config,
            (nothing, nothing),
            (nothing, nothing),
            DataFrame(),
            DataFrame(),
            Array{AbstractGraph, 1}(undef, 0)
        )
    end

end

function tick!(
    state::Tuple{AbstractGraph, AbstractArray}, post_list::AbstractArray,
    tick_nr::Int64, config::Config
)
    agent_list = state[2]
    for agent_idx in shuffle(1:length(agent_list))
        this_agent = agent_list[agent_idx]
        update_feed!(state, agent_idx, config)
        update_perceiv_publ_opinion!(state, agent_idx)
        update_opinion!(state, agent_idx, config)

        drop_friends!(state, agent_idx, config)
        if indegree(state[1], agent_idx) < config.network.m0
            if config.simulation.addfriends == "neighborsofneighbors"
                add_friends_neighbors_of_neighbors!(
                    state, agent_idx, post_list,
                    config, config.network.new_follows
                )
            elseif config.simulation.addfriends == "random"
                add_friends_random!(
                    state, agent_idx, post_list,
                    config, config.network.new_follows
                )
            else
                add_friends_neighbors_of_neighbors!(
                    state, agent_idx, post_list,
                    config, floor(Int,config.network.new_follows/2)
                )
                add_friends_random!(
                    state, agent_idx, post_list,
                    config, floor(Int,config.network.new_follows/2)
                )
            end
        end

        inclin_interact = deepcopy(this_agent.inclin_interact)
        while inclin_interact > 0
            if rand() < inclin_interact
                publish_post!(state, post_list, agent_idx, tick_nr)
            end
            inclin_interact -= 1.0
        end
    end
    return log_network(state, tick_nr)
end

function run!(
    simulation::Simulation=Simulation();
    name::String = "result"
    )

    config = simulation.config

    graph = DiGraph(barabasi_albert(
                    config.network.agent_count,
                    config.network.m0))
    simulation.init_state = (graph, create_agents(graph))
    state = deepcopy(simulation.init_state)
    post_log = Array{Post, 1}(undef, 0)
    simulation.graph_list = Array{AbstractGraph, 1}([simulation.init_state[1]])

    agent_log = DataFrame(
        TickNr = Int64[],
        AgentID = Int64[],
        Opinion = Float64[],
        PerceivPublOpinion = Float64[],
        Indegree = Int64[],
        Outdegree = Int64[],
        Centrality = Float64[],
        CC = Float64[],
        Component = Int64[]
    )

    if !in("tmp", readdir())
        mkdir("tmp")
    end
    if name == "result"
        print("Current Tick: 0")
    end

    for i in 1:config.simulation.ticks

        if name == "result"
            print('\r')
            print("Current Tick: $i, current AVG agents connection count::" * string(round(mean(degree(state[1])))) * ", max outdegree: " * string(maximum(outdegree(state[1]))) * ", current Posts: " * string(length([post for post in post_log if length(post.seen_by) > 0])))
        end
        append!(agent_log, tick!(state, post_log, i, config))
        if i % ceil(config.simulation.ticks / 10) == 0
            if name != "result"
                print(".")
            end

            push!(simulation.graph_list, state[1])

            simulation.final_state = state
            simulation.agent_log = agent_log
            simulation.post_log = post_log

            save(joinpath("tmp", name * ".jld2"), string(i), simulation)
        end
    end

    simulation.final_state = state
    simulation.agent_log = agent_log
    simulation.post_log = DataFrame(
        Opinion = [p.opinion for p in post_log],
        Weight = [p.weight for p in post_log],
        Source_Agent = [p.source_agent for p in post_log],
        Published_At = [p.published_at for p in post_log],
        Seen = [p.seen_by for p in post_log]
    )

    if !in("results", readdir())
        mkdir("results")
    end
    save(joinpath("results", name * ".jld2"), name, simulation)
    rm(joinpath("tmp", name * ".jld2"))

    print("\n---\nFinished simulation run with the following specifications:\n $config\n---\n")

    return simulation
end

function run_batch(
    configlist::Array{Config, 1};
    resume_at::Int64=1,
    stop_at::Int64=length(configlist),
    batch_name::String = ""
    )

    for i in resume_at:stop_at
        run_nr = lpad(string(i),length(string(length(configlist))),"0")
        run!(
            Simulation(configlist[i]),
            name = (batch_name * "_run$run_nr")
        )
    end
end

# suppress output of include()
;
