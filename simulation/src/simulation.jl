using LightGraphs
using DataFrames
using Random
using Statistics
using JLD
using JLD2
using StatsBase


for script in readdir("src")
    if script != "simulation.jl"
        include(script)
    end
end

function tick!(
    state::Tuple{AbstractGraph, AbstractArray}, post_list::AbstractArray,
    tick_nr::Int64, config::Config
)
    agent_list = state[2]
    for agent_idx in shuffle(1:length(agent_list))
        this_agent = agent_list[agent_idx]
        if this_agent.active
            this_agent.inactive_ticks = 0
            update_feed!(state, agent_idx, config)
            update_perceiv_publ_opinion!(state, agent_idx)
            update_opinion!(state, agent_idx, config)

            drop_input!(state, agent_idx, config)
            if indegree(state[1], agent_idx) < config.network.m0
                if config.simulation.addinput == "neighborsofneighbors"
                    add_input_neighbors_of_neighbors!(state, agent_idx, post_list, config, config.network.new_follows)
                elseif config.simulation.addinput == "random"
                    add_input_random!(state, agent_idx, post_list, config, config.network.new_follows)
                else
                    add_input_neighbors_of_neighbors!(state, agent_idx, post_list, config, floor(Int,config.network.new_follows/2))
                    add_input_random!(state, agent_idx, post_list, config, floor(Int,config.network.new_follows/2))
                end
            end
            publish_post!(state, post_list, agent_idx, tick_nr)

        elseif this_agent.active
            this_agent.inactive_ticks += 1
            if this_agent.inactive_ticks > 2
                set_inactive!(state, agent_idx, post_list)
            end
        end
    end
    return log_network(state, tick_nr)
end

function simulate(
    config::Config = Config();
    batch_desc::String = "result"
    )

    graph = barabasi_albert(
                    config.network.agent_count,
                    config.network.m0,
                    config.network.new_follows)
    init_state = (graph, create_agents(graph))
    state = deepcopy(init_state)
    post_list = Array{Post, 1}(undef, 0)
    graph_list = Array{AbstractGraph, 1}([init_state[1]])

    df = DataFrame(
        TickNr = Int64[],
        AgentID = Int64[],
        Opinion = Float64[],
        PerceivPublOpinion = Float64[],
        InactiveTicks = Int64[],
        ActiveState = Bool[],
        Indegree = Int64[],
        Outdegree = Int64[]
    )

    if !in("tmp", readdir())
        mkdir("tmp")
    end
    if batch_desc == "result"
        print("Current Tick: 0")
    end

    for i in 1:config.simulation.ticks
        current_network = deepcopy(state[1])
        rem_vertices!(current_network, [agent.id for agent in state[2] if !agent.active])
        if batch_desc == "result"
            print('\r')
            print("Current Tick: $i, current AVG agents connection count::" * string(round(ne(current_network)/nv(current_network))) * ", max outdegree: " * string(maximum(outdegree(current_network))) * ", mean outdegree: " * string(mean(outdegree(current_network))) * ", current Posts: " * string(length(post_list)))
        end
        append!(df, tick!(state, post_list, i, config))
        if i % ceil(config.simulation.ticks / 10) == 0
            if batch_desc != "result"
                print(".")
            end
            push!(graph_list, current_network)

            save(joinpath("tmp", batch_desc * "_tmpstate.jld2"), string(i), (string(config), (df, post_list, graph_list), state, init_state))
        end

    end

    post_df = DataFrame(
        Opinion = [p.opinion for p in post_list],
        Weight = [p.weight for p in post_list],
        Source_Agent = [p.source_agent for p in post_list],
        Published_At = [p.published_at for p in post_list],
        Seen = [p.seen_by for p in post_list]
    )

    if !in("results", readdir())
        mkdir("results")
    end
    save(joinpath("results", batch_desc * ".jld2"), batch_desc, (config, (df, post_df, graph_list), state, init_state))
    rm(joinpath("tmp", batch_desc * "_tmpstate.jld2"))

    print("\n---\nFinished simulation run with the following specifications:\n $config\n---\n")
end

# suppress output of include()
;
