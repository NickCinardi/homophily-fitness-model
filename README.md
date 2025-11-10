# homophily-fitness-model: how to use it

We provide here codes to build a network as described in https://doi.org/10.31235/osf.io/sp8kn
and define functions to analyze key metrics. 

This code requires "Julia" to be installed 
https://docs.julialang.org/en/v1/manual/installation/ 

A series of packages is required. 
Follow the instructions on how to install them (see an example at https://docs.juliaplots.org/dev/install/#Install)
or read documentation at https://julialang.org/packages/


The file "build_network.jl" contains the code to build the graph with the desired number of vertices, homophily parameters, and node fitness (the amount of 'resources' to be assigned to each node). 

If the number of nodes is under 200, a graphical representation of the network is automatically generated.

The function 'creategrpah' by default returns as output the network itself and the degrees of nodes in the minority group (a) and majority group (b). Commenting and uncommenting (through '#') lines inside the function allows the function to return desired quantities. 
To access the first object returned by the function, use the key creategraph(...)[1] (similarly to accessing objects 2 and 3).

The file "functions_for_analysis.jl" provides the code to define key functions.  
By default, they take the graph (or the degrees) as input and return the given measures. 

The file "example_of_usage.jl" opens the other two files ("build_network.jl" and "functions_for_analysis.jl") creates a graph with some parameters of choice through the formula

g=creategraph(...)

and computes rich-club coefficient (in function of structural degrees), connectivity fractions within and between groups, and the Gini coefficients on degree distributions, respectively with  

rich_club_coefs(g[1])
connectivity_in_and_out_group(g[1])
gini_ka, gini_kb=gini_on_degrees(g[2]), gini_on_degrees(g[3])





