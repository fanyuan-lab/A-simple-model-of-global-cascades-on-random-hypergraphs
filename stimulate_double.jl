using Random
using Distributions
using DelimitedFiles
using Statistics


function create_HG(N,M,mean_m)  #The case of following a Poisson distribution
    edge_list = []
    edge_m = rand(Poisson(mean_m),M)  

    node_edge_dict = Dict()
    for j in 1:N 
        node_edge_dict[j] = Int64[]
    end

    for i in 1:M
        edge = sample(1:N,edge_m[i],replace=false) 
        push!(edge_list,edge)
        for j in edge 
            append!( node_edge_dict[j],i)
        end
    end
    return edge_list,node_edge_dict #Output edge set and adjacency list
end



function main_work_er(N,M,ave_m,r,phi1,phi2)
    
    edge_list,adj_node_edge = create_HG(N,M,ave_m)


    init_delete_nodes = sample(1:N,round(Int,N*r),replace = false)

    delete_nodes  = []
    append!(delete_nodes,init_delete_nodes)

    flags = zeros(Int,M)

    while true
 
        #Edge activation
        for i in 1:M                                 
            if length(edge_list[i])>0 
                if flags[i] == 0
                    fraction = length(intersect(edge_list[i], delete_nodes))/length(edge_list[i])  
                    if  fraction >= phi2
               
                        flags[i]=1 
                    end
                end
            end
        end

        #Node activation
        delete_nodes_nodes = []
        for j in 1:N
           if !(j in delete_nodes)
                sum = 0
                if length(adj_node_edge[j]) != 0  
                    for n in adj_node_edge[j]  
                        if flags[n] == 1
                            sum += 1
                        end
                    end
                    fraction = sum /length(adj_node_edge[j])
                    if fraction >= phi1
                        push!(delete_nodes_nodes,j)
                    end
                end
            end
        end

       
        if length(delete_nodes_nodes) == 0
            break
        end

       
        append!(delete_nodes,delete_nodes_nodes)
        delete_nodes = collect(Set(delete_nodes))
      
    end


    return length(delete_nodes)/N
end




N = 100000 #the number of nodes
M = 100000 #the number of edges
ave_m = 3 # average cardinality 

phi1 = 0.1 #the threshold of node
phi2 = 0.1#the threshold of edge


main_work_er(N,M,ave_m,r,phi1,phi2)
