using Statistics, Graphs, MetaGraphs

""" Compute the rich-club coefficients of a given graph G 
    It returns two arrays: the degree values and the corresponding rich-club coefficients
"""
function rich_club_coefs(G)
    # Rich-club coefficient calculation (unmute return G in creategraph function to use)
    degrees=[Graphs.degree(G,i) for i in collect(Graphs.vertices(G))]
    kk=Statistics.mean(degrees)
    ks=Int(round( sqrt(kk*nv(G)) ))
    x_rc=collect(minimum(degrees):5:ks)
    y_rc=round.(digits=4, [Graphs.rich_club(G, i) for i in x_rc])
    return x_rc, y_rc
end


""" It computes the connectivity inside and outside groups
    It returns the fraction of edges inside group a (Eaa), inside group b (Ebb) and between groups (Ecc)
"""

function connectivity_in_and_out_group(G)
    # Compute edge types counts (unmute return G in creategraph function to use)
    Naa=filter_edges(G, :h, "a-a")
    Nab=filter_edges(G, :h, "a-b")
    Nba=filter_edges(G, :h, "b-a")
    Nbb=filter_edges(G, :h, "b-b")
    laa=length(collect(Naa))
    lab=length(collect(Nab))
    lba=length(collect(Nba))
    lbb=length(collect(Nbb))
    Eaa, Ebb, Ecc=laa/(laa+lab+lba), lbb/(lbb+lab+lba), (lab+lba)/(lbb+lab+lba+laa)
    return Eaa, Ebb, Ecc
end





""" Given the degree sequences of the two groups ka and kb (uncomment them to use in creategraph function)
    It computes the Gini index for the in-group nodes degrees
"""
function gini_on_degrees(x::Vector{Int64})
    # Compute Gini index (unmute return ka. kb in creategraph function to use)
    Gini=Vector{Int64}()
    A = sum([abs(i-j) for i in x, j in x])
    Gini=sum(A)/(2*((length(x))^2)*mean(x))
    return Gini
end

