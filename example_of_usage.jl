
include("build_network.jl")
include("functions_for_analysis.jl")



""" Example of graph creation with N=200, h=0.2, m=5, Δμ=5, σ=5
"""
g=creategraph(200,0.2,5, 2.0,5)




""" The first object returned in creategraph is the graph itself with properties of nodes and links
"""

rich_club_coefs(g[1])
connectivity_in_and_out_group(g[1])



""" The second and third objects returned in creategraph are vectors containing the degrees of nodes in each group
"""
gini_ka, gini_kb=gini_on_degrees(g[2]), gini_on_degrees(g[3])
