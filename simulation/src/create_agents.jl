function create_agents(graph::AbstractGraph)

    agent_list = Array{Agent, 1}(undef, length(vertices(graph)))
    for agent_idx in 1:length(agent_list)
        agent_list[agent_idx] = Agent(
            agent_idx,
            2 * rand() - 1
        )
    end
    return agent_list
end

# suppress output of include()
;
