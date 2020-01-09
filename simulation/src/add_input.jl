function add_input_neighbors_of_neighbors!(
    state::Tuple{AbstractGraph, AbstractArray},
    agent_idx::Integer,
    post_list::AbstractArray,
    config::Config,
    new_input_count::Int64
)
    graph, agent_list = state
    this_agent = agent_list[agent_idx]
    # neighbors of neighbors
    input_candidates = Int64[]

    for neighbor in inneighbors(graph, agent_idx)
        append!(input_candidates, setdiff(inneighbors(graph, neighbor), inneighbors(graph, agent_idx)))
    end

    if length(input_candidates) == 0 && indegree(graph, agent_idx) <= config.agent_props.min_input_count
        set_inactive!(state, agent_idx, post_list)
        this_agent.inactive_ticks = -1
        return state
    end
    shuffle!(input_candidates)
    # order neighbors by frequency of occurence in input_candidates descending
    input_queue = first.(sort(collect(countmap(input_candidates)), by=last, rev=true))

    if (length(input_queue) - config.network.new_follows) < 0
        new_input_count = length(input_queue)

    for _ in 1:new_input_count
        new_neighbor = popfirst!(input_queue)
        add_edge!(graph, new_neighbor, agent_idx)
        end
    end
    return state
end

function add_input_random!(
    state::Tuple{AbstractGraph, AbstractArray},
    agent_idx::Integer,
    post_list::AbstractArray,
    config::Config,
    new_input_count::Int64
    )
    graph, agent_list = state
    this_agent = agent_list[agent_idx]

    input_queue = Array{Tuple{Int64,Int64}, 1}()
    not_neighbors = setdiff([1:(agent_idx - 1); (agent_idx + 1):nv(graph)], inneighbors(graph, agent_idx))
        for candidate in not_neighbors
            if abs(this_agent.opinion - agent_list[candidate].opinion) < config.opinion_threshs.follow
                push!(input_queue, (candidate, outdegree(graph, candidate)))
        end
    end

    input_queue = first.(sort(input_queue, by=last, rev=true))

    if (length(input_queue) - config.network.new_follows) < 0
        new_input_count = length(input_queue)

    for _ in 1:new_input_count
        new_neighbor = popfirst!(input_queue)
        add_edge!(graph, new_neighbor, agent_idx)
        end
    end
    return state
end

# suppress output of include()
;
