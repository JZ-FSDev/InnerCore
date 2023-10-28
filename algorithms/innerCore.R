library("data.table")
library("RSQLite")
library("igraph")

#' innerCore of nodes in a complex, directed network
#'
#' \code{innerCore} returns a dataframe of nodes that constitute the target innercore
#'
#' A modification of alphaCore (https://github.com/friedhelmvictor/alphacore)
#' allowing for a more efficient and direct identification of an innerCore. 
#' Computes a graph's innercore based on a feature set derived from edge attributes 
#' and optionally static node features using the mahalanobis data depth function at 
#' the origin.
#'
#' @param input_graph An igraph object of a directed graph
#' @param epsilon Defines the upper bound of depth for a target innercore
#' @param returnGraph Toggles the return type of the function
#' @param featureComputeFun A function that converts a node's edges (with
#'   attributes) into node features. Default computes in-degree, out-degree, 
#'   in-strength, and out-strength
#' @return A dataframe of nodes from input_graph of depth < epsilon
innerCore <- function(input_graph,
                      epsilon = 0.25,
                      returnGraph = FALSE,
                      featureComputeFun = computeNodeFeaturFun) {
  
  #1
  node_features = featureComputeFun(input_graph)
  #2
  cov_mat_inv <- solve(cov(node_features[, -c("node")]), tol = NULL)
  #3
  node_features$depth <- mhdOrigin(node_features[, !c("node")], cov_mat_inv)
  #4
  repeat{
  #5 & #6
    nodes <- node_features[depth >= epsilon]$node
    
    input_graph <- delete_vertices(input_graph, nodes)
  #7  
    node_features = featureComputeFun(input_graph)
  #8  
    node_features$depth <- mhdOrigin(node_features[, !c("node")], cov_mat_inv)
  #9  
    if(length(nodes) == 0){
      break
    }
  }
  #11
  if(returnGraph){
    result = input_graph
  }else{
    result <- node_features[, c("node")]
  }
  
  return (result)
}


############################## AUX FUNCTIONS ################################

computeNodeFeaturFun <- function(graph) {
  # get node names
  nodes <- V(graph)$name
  # compute indegree
  indegree <- degree(graph, mode = "in")
  # compute sum of incoming weights (a.k.a. "strength")
  strength <- strength(graph, mode="in")
  # compute outdegree
  outdegree <- degree(graph, mode = "out")
  # compute sum of outgoing weights (a.k.a. "strength")
  outstrength <- strength(graph, mode="out")
  # combine results
  nodeFeatures <- data.table(node=nodes, indegree=indegree, strength=strength, outdegree=outdegree, outstrength=outstrength)
  return(nodeFeatures)
}

computeNodeFeatures <- function(graph, features) {
  nodeFeatures <- data.table(node = V(graph)$name)
  if("degree" %in% features) {
    nodeFeatures[, indegree := degree(graph, mode = "all")]
  }
  if("indegree" %in% features) {
    nodeFeatures[, indegree := degree(graph, mode = "in")]
  }
  if("outdegree" %in% features) {
    nodeFeatures[, outdegree := degree(graph, mode = "out")]
  }
  if("strength" %in% features) {
    nodeFeatures[, strength := strength(graph, mode = "all")]
  }
  if("instrength" %in% features) {
    nodeFeatures[, instrength := strength(graph, mode = "in")]
  }
  if("outstrength" %in% features) {
    nodeFeatures[, outstrength := strength(graph, mode = "out")]
  }
  if("triangles" %in% features) {
    nodeFeatures[, triangles := count_triangles(graph)]
  }
  if("neighborhoodsize" %in% features) {
    nodeFeatures[, neighborhoodsize := neighborhood.size(graph, mode = "all", mindist = 1)]
  }
  if("inneighborhoodsize" %in% features) {
    nodeFeatures[, inneighborhoodsize := neighborhood.size(graph, mode = "in", mindist = 1)]
  }
  if("outneighborhoodsize" %in% features) {
    nodeFeatures[, outneighborhoodsize := neighborhood.size(graph, mode = "out", mindist = 1)]
  }
  return(nodeFeatures[])
}

customNodeFeatures <- function(features) {
  return(function(x) {
    return(computeNodeFeatures(x, features = features))
  })
}


mhdOrigin <- function(data, sigma_inv) {
  origin <- rep(0,ncol(data)) # c(0,0,...)
  # We reuse the Mahalanobis distance implementation of the stats package,
  # which returns the squared Mahalanobis distance: (x - μ)' Σ^-1 (x - μ) = D^2
  # To arrive at the Mahalanobis Depth to the origin, we only need to add 1 and
  # take the reciprocal.
  return((1 + stats::mahalanobis(data, center = origin, sigma_inv, inverted = TRUE))^-1)
}


############################## UTILITY FUNCTIONS ################################

#' innerCore vertex identification in each daily temporal network from a large dataset
#' of transfers 
#'
#' \code{temporalInnerCoreToCSV} saves each daily temporal innercore as a .csv file
#'
#' Calls the innerCore function repeatedly for each daily temporal network 
#' generated from an input .csv dataset of transfer data from UNIX timestamp start 
#' to end (inclusive) and saves the vertices of each day's innercore as a .csv file 
#' in the form innerCore_025_1661126400.csv where 025 denotes an epsilon value 
#' of 0.25 and 1661126400 denotes the timestamp.
#'
#' @param epsilon Defines the upper bound of depth for the target innercore of 
#'   each day
#' @param start The UNIX timestamp of the first day
#' @param end The UNIX timestamp of the last day (inclusive)
#' @param data Name of the .csv file containing the transfer data
#' @param senderColName Name of the column from data containing the sender
#' @param recipientColName Name of the column from data containing the recipient
#' @param timestampColName Name of the column containing the timestamp
#' @param valueColName Name of the column containing the value
#' @param colClass The column classes of the data file as a vector
temporalInnerCoreToCSV <- function(epsilon, 
                                   start, 
                                   end, 
                                   data,
                                   senderColName,
                                   recipientColName,
                                   timestampColName,
                                   valueColName,
                                   colClass) {
  df = read.csv(data, colClasses = colClass)
  readIndex = 1
  currDay = start
  currDayEnd = start + 86400

  while(currDay != end + 86400){
    to_address = c()
    from_address = c()
    weight = c()

    writeIndex = 1
    for (row in readIndex:nrow(df)) {
      if(currDay <= df[[timestampColName]][row] & df[[timestampColName]][row] < currDayEnd){
        to_address[writeIndex] = df[[recipientColName]][row]
        from_address[writeIndex] = df[[senderColName]][row]
        weight[writeIndex] = df[[valueColName]][row]
        writeIndex = writeIndex + 1
      }
      readIndex = readIndex + 1
      if(df[[timestampColName]][row] > currDayEnd){
        break
      }
    }
    df2 = data.frame(from_address, to_address, weight)
    g = graph_from_data_frame(df2, directed = TRUE, vertices = NULL)
    a = innerCore(g, epsilon)
    outFile = "innerCore_"
    outFile = paste(outFile, as.character(epsilon))
    outFile = paste(outFile, "_")
    outFile = paste(outFile, as.character(currDay))
    outFile = gsub("\\.", "", outFile)
    outFile = paste(outFile, ".csv")
    outFile = gsub(" ", "", outFile)
    
    write.csv(a, outFile, row.names = TRUE)
  
    currDayEnd = currDayEnd + 86400
    currDay = currDay + 86400
  }
}


#' 3-node motif counts of each node of an input igraph
#'
#' \code{countThreeNodeMotifs} returns a dataframe of the 3-node motifcounts of each node
#'
#' Motifs are described in the following link: https://igraph.org/r/doc/triad_census.html
#' and numbered in relative order as listed in the link.  A count for a node of a
#' particular motif is defined simply as the node existing as any one of the 
#' three vertices in the motif.
#'
#' @param input_graph An igraph object of a directed graph
#' @return A dataframe of each node from the input_graph with each of its connected 
#'   3-node motif counts
countThreeNodeMotifs <- function(input_graph){
  df <- data.frame(matrix(ncol = 17, nrow = 0))
  headings <- c("node", "motif1", "motif2", "motif3", "motif4", "motif5", "motif6", "motif7", "motif8",
         "motif9", "motif10", "motif11", "motif12", "motif13", "motif14", "motif15", "motif16")
  colnames(df) <- headings
  
  components = components(input_graph)
  numLoneNodes = sum(components$csize == 1)
  
  names = V(input_graph)$name
  for(node in names){
    subGraph = graph.neighborhood(input_graph, order = 1, node, mode = 'all')[[1]]
    allMotifs = triad.census(subGraph)
    removeNode = delete.vertices(subGraph, node)
    nodeMotifs = allMotifs - triad.census(removeNode)
    if(vcount(subGraph) == 2){
      first_in_degree <- degree(subGraph, v = 1, mode = "in")
      first_out_degree <- degree(subGraph, v = 1, mode = "out")
      nodeMotifs[3] = first_in_degree * first_out_degree * numLoneNodes
      nodeMotifs[2] = (first_in_degree + first_out_degree) * numLoneNodes
    }else if(vcount(subGraph) == 1){
      nodeMotifs[1] = choose(numLoneNodes - 1, 2)
    }
    df[nrow(df) + 1,] <- c(node, nodeMotifs)
  }
  
  return (df)
}
