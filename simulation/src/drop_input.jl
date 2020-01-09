function drop_input!(
    state::Tuple{AbstractGraph, AbstractArray},
    agent_idx::Integer,
    config::Config
)
    graph, agent_list = state
    this_agent = agent_list[agent_idx]
    # look for current input posts that have too different opinion compared to own
    # and remove them if source agent opinion is also too different
    unfollow_candidates = Array{Tuple{Int64, Int64}, 1}()
    for post in this_agent.feed
        if abs(post.opinion - this_agent.opinion) > config.opinion_threshs.unfollow
            if abs(agent_list[post.source_agent].opinion - this_agent.opinion) > config.opinion_threshs.unfollow
                # Remove agents with higher follower count than own only with certain probability?
                push!(unfollow_candidates, (post.source_agent, indegree(graph, post.source_agent)))
            end
        end
    end
    sort!(unfollow_candidates, by=last)
    for i in 1:min(length(unfollow_candidates), ceil(Int64, indegree(graph,agent_idx) * config.agent_props.unfollow_rate))
        rem_edge!(graph, unfollow_candidates[i][1],agent_idx)
    end
    return state
end

# suppress output of include()
;
