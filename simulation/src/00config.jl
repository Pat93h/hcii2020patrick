
function cfg_net(
    ;
    agent_count::Int64=1000,
    m0::Int64=100,
    new_follows::Int64=4
)
    return (
        agent_count=agent_count,
        m0=m0,
        new_follows=new_follows
    )
end

function cfg_sim(
    ;
    ticks::Int64=100,
    addinput::String=""
    )

    return(
        ticks=ticks,
        addinput=addinput
    )
end

function cfg_ot(
    ;
    backfire::Float64=0.4,
    follow::Float64=0.2,
    unfollow::Float64=0.5
)
    return (
        backfire=backfire,
        follow=follow,
        unfollow=unfollow
    )
end

function cfg_ag(
    ;
    own_opinion_weight::Float64=0.95,
    unfollow_rate::Float64=0.05,
    min_input_count::Int64=5
    )

    return (
        own_opinion_weight=own_opinion_weight,
        unfollow_rate=unfollow_rate,
        min_input_count=min_input_count
    )
end

struct Config
    network::NamedTuple{
        (:agent_count, :m0, :new_follows),
        NTuple{3,Int64}
    }
    simulation::NamedTuple{
    (:ticks, :addinput),
    <:Tuple{Int64, String}
    }
    opinion_threshs::NamedTuple{
        (:backfire, :follow, :unfollow),
        NTuple{3,Float64}
    }
    agent_props::NamedTuple{
    (:own_opinion_weight, :unfollow_rate, :min_input_count),
    <:Tuple{Float64, Float64, Int64}
    }

    # constructor
    function Config(
        ;
        network = cfg_net(),
        simulation = cfg_sim(),
        opinion_threshs = cfg_ot(),
        agent_props = cfg_ag()
    )
        new(network, simulation, opinion_threshs, agent_props)
    end
end
