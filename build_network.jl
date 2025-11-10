"""To create the graph, the following packages are needed
"""

using MetaGraphs, Graphs, StatsBase, Distributions, DataStructures, GraphPlot, Compose, Cairo

function creategraph(N::Int, h::Float64, m::Int64, mul::Float64,sig::Int64)  
    G=MetaGraph(N)
    """ Pick value of _mu_a and mu_b (respectively the minority and majority fitness means)
        If you want mu_a<mu_b set mua and then mub=mua+mul otherwise set mub and then mua=mub+mul
    """
    mua=10.0       
    mub=mua + mul

    """ Set values for standard deviations of fitness distributions (assuming a Gaussian distribution)
        By default, both are equal to sig, but you can change them if needed
    """
    siga=sig    
    sigb=sig 

    """ Set the fraction of minority nodes, get an integer number of nodes for each group
    By default, it is 1/5 of total nodes, modify accordingly if needed
    """
    fa=round(Int64,1/5*N)    
    fb=N-fa

    """ Collect vertices and assign fitness values to nodes in groups
    """
    vertici=collect(Graphs.vertices(G))
    b=StatsBase.sample(vertici, fb; replace=false)
    a=setdiff!(vertici,b)
    vertici=collect(Graphs.vertices(G))

    """ To avoid negative fitness values, we use a truncated Gaussian distribution
    """
    for i in a
        set_prop!(G, i, :eta,round(rand(Truncated(Normal(mua,siga),0,2mua),1)[1],digits=4))
    end
    for i in b
        set_prop!(G, i, :eta,round(rand(Truncated(Normal(mub,sigb),0,2mub),1)[1],digits=4))
    end

    """ Assign colors to nodes based on their group
    """
    C=Dict{Int,String}()
    for i in b
        set_prop!(G, i, :col, "b")
        C[i]="#2b83ba" #"blue"
    end
    for i in a
        set_prop!(G, i, :col, "a")
        C[i]="#fdae61" #"yellow-orange"
    end

    """ Precompute homophily values for each pair of nodes
    """
    H=Dict{Vector{},Float64}()

    for i in vertici
        for j in vertici
            if get_prop(G, i, :col)==get_prop(G, j, :col)
                H[[i,j]]=h
            else
                H[[i,j]]=1-h
            end
        end
    end


    """ Build the graph
    """
    attuali=Vector{Int64}()
    rimanenti=vertici

    for i in 1:N
        node=StatsBase.sample(rimanenti, 1; replace=false)[1]
        push!(attuali,node)
        rimanenti=setdiff!(vertici,node)
        len=length(attuali)

        if len==1
            continue
        elseif len==2
            precedentnode=[i for i in attuali if i!=node]
            Graphs.add_edge!(G,node,precedentnode[1])
        else
            prod=OrderedDict{Int,Float64}()
            k=OrderedDict{Int,Float64}()
            for j in attuali
                if j!=node
                    k[j]=Graphs.degree(G,j)
                    prod[j]=k[j]*H[[node,j]]*get_prop(G, j, :eta)
                end
            end
            v=collect(values(prod))
            p=v./sum(v)

            if len<=m
                winners=sample(v,StatsBase.Weights(p),len-1,replace=false)
            else
                winners=sample(v,StatsBase.Weights(p),m,replace=false)
            end

            vp=[k for (k,l) in prod if l ∈winners]

            c=get_prop(G, node, :col)
            for i in vp
                Graphs.add_edge!(G,node,i)
                if c=="a" && get_prop(G, i, :col)=="a"
                    set_prop!(G,node,i,:h,"a-a")
                elseif c=="a" && get_prop(G, i, :col)=="b"
                    set_prop!(G,node,i,:h,"a-b")
                elseif c=="b" && get_prop(G, i, :col)=="a"
                    set_prop!(G,node,i,:h,"b-a")
                else
                    set_prop!(G,node,i,:h,"b-b")
                end
            end
        end
    end

    vertici=collect(Graphs.vertices(G))

    """ Plot the graph if not too big
    """
    if N<=200
        colors=[C[i] for i in vertici]
        S=Dict{Int64,Float64}()
        """ Pick a scaling factor for the node sizes
        """
        s=1.2
        for v in vertici
            if mub>mua
                if get_prop(G, v, :col)=="b"
                    S[v]=get_prop(G, v, :eta)           
                else
                    S[v]=get_prop(G, v, :eta)/s          
                end
            elseif mub<mua
                if get_prop(G, v, :col)=="a"
                    S[v]=get_prop(G, v, :eta)           
                else
                    S[v]=get_prop(G, v, :eta)/s          
                end
            else
                S[v]=get_prop(G, v, :eta)
            end
        end
        nodesize = [S[v] for v in vertici]
        mas=maximum(nodesize)
        nodesize = nodesize./(12*mas)

        for v in vertici
            theta=rand(Uniform(0,2pi))                             #random angle
            d=Graphs.degree(G, v)+rand(Uniform(0.1,0.6))           #to avoid overlapping nodes 
            set_prop!(G, v, :pos, [1/d*cos(theta),1/d*sin(theta)]) #positioning nodes in a circular layout
        end

        EC=Dict{Any,String}()
        for e in edges(G)
          if get_prop(G, src(e)  , :col) == get_prop(G, dst(e)  ,:col)
              EC[e]=C[src(e)]
          else
              EC[e]="#abdda4" #"green"
          end
        end
        ecolors=[EC[i] for i in edges(G) ]
    
        xnodes=[get_prop(G, i, :pos)[1] for i in 1:N]
        ynodes=[get_prop(G, i, :pos)[2] for i in 1:N]

        g=GraphPlot.gplot(G, nodefillc=colors, edgestrokec=ecolors,nodestrokec="black",nodestrokelw=0.01,
            NODESIZE=nodesize,EDGELINEWIDTH=0.2, xnodes,ynodes, )
        draw(PDF("Visual representation of graph.pdf"), g)
    else
        println("Network too big to be plotted nicely")
        println("Network is created anyway, having properties N=$N, h=$h, μa=$(mua), μb=$(mub), σ=$(sig)")
    end

    """ Collect degree of all nodes (remove # to use:)
    """
    # degrees=[Graphs.degree(G,i) for i in collect(Graphs.vertices(G))]

    """ Degree distributions of the two groups (remove # to use add # to mute them:)
    """
    ka=[Graphs.degree(G,i) for i in a]
    kb=[Graphs.degree(G,i) for i in b]


    """ What to return (uncomment as needed)
    """
    #return ka, kb
    #return degrees
    #return G
    return G, ka, kb
end


