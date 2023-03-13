# InnerCore

These are the supplementary files for the [Core-based Trend Detection paper](link).

## Usage
Until this is packaged, source the file(s) `algorithms/innerCore.R` or `utils.py`

### Get a weighted directed graph with named vertices and edge weights:
```R
g <- erdos.renyi.game(200, 2/200, directed = T)
E(g)$weight <- 1:ecount(g)
V(g)$name <- paste("v", 1:vcount(g), sep="")
```

### Run innerCore with default parameters
```R
> innerCore(g)
     node
  1:   v2
  2:   v3
  3:   v4
  4:   v5
  5:   v6
 ---     
148: v194
149: v195
150: v197
151: v198
152: v200
```

### Run innerCore with builtin edge property functions
```R
> innerCore(g, featureComputeFun = customNodeFeatures(c("indegree", "triangles")))
    node
 1:   v1
 2:   v2
 3:   v3
 4:   v4
 5:   v7
 --- 
31: v168
32: v169
33: v173
34: v183
35: v200
```


### Get the 3-node motif counts of each node using the utility function in `innerCore.R`
```R
> countThreeNodeMotifs(g)
  node motif1 motif2 motif3 motif4 motif5 motif6 motif7 motif8 motif9 motif10 motif11 motif12 motif13 motif14 motif15 motif16
1   v1      0      0      0      3      0      0      0      0      0       0       0       0       0       0       0       0
2   v2      0      0      0     15      1     12      0      0      0       0       0       0       0       0       0       0
3   v3      0      4      0      0      0      0      0      0      0       0       0       0       0       0       0       0
4   v4      0      0      0      1      0      2      0      0      0       0       0       0       0       0       0       0
5   v5      0      0      0      0      3      3      0      0      0       0       0       0       0       0       0       0
 ---
196 v196    3      0      0      0      0      0      0      0      0       0       0       0       0       0       0       0
197 v197    0      0      0      6      0      4      0      0      0       0       0       0       0       0       0       0
198 v198    0      0      0      1      1      4      0      0      0       0       0       0       0       0       0       0
199 v199    0      0      0      1      3      6      0      0      0       0       0       0       0       0       0       0
200 v200    0      0      0      3      3      9      0      0      0       0       0       0       0       0       0       0
```


### Computing expansion and decay measures of daily temporal networks
For an example directory with the following files:
```
eth_innerCore_025_1661126400.csv
eth_innerCore_025_1661212800.csv
eth_innerCore_025_1661299200.csv
```
where each file contains the addresses of the innercore of a day is in the form:
```
	node
1	0x91aae0aafd9d2d730111b395c6871f248d7bd728
2	0xa6807d794411d9a80bc435dfc4cda0ba0ddde979
3	0x0084dfd7202e5f5c0c8be83503a492837ca3e95e
4	0x5041ed759dd4afc3a72b8192c143f72f4724081a
5	0xffec0067f5a79cff07527f63d83dd5462ccf8ba4
        ---    
```
Call `computeExpansionDecay` from `utils.py`:
```py
>>> computeExpansionDecay(1, 1661126400, 1661299200, "eth_innerCore_025_", "node")
```
to produce the results file `expansion_decay_1661212800_to_1661299200_i=1.csv` in the form:
```
	timestamp	expansion	decay
0	1661212800	0.387921022	0.516840883
1	1661299200	0.414666667	0.514666667
```


### Compute the motif NF-IAF scores of each address of each day
For an example directory with the following files:
```
alphaCore_1648857600_motif4.csv
alphaCore_1648944000_motif4.csv
alphaCore_1649030400_motif4.csv
```
where each file contains the motif counts of each address of each day in the form:
```
        addresses	                                occurrences
1	0x28c6c06298d514db089934071355e5743bf21d60	847
2	0xdfd5293d8e347dfe59e90efd55b2956a1343963d	799
3	0x56eddb7aa87536c09ccc2793473599fd21a8b17f	577
4	0x876eabf441b2ee5b5b0554fd502a8e0600950cfa	136
5	0xba12222222228d8ba445958a75a0704d566bf2c8	113
        ---    
```
Call `computeNFIAF` from `utils.py`:
```py
>>> computeNFIAF(1648857600, 1649030400, ["motif4"], "alphaCore_", "addresses", "occurrences")
```
to produce the results file `nfiaf_1648857600_to_1649030400_motif4.csv` in the form:
```
	address	                                        timestamp	nfiaf
0	0xba12222222228d8ba445958a75a0704d566bf2c8	1648857600	0.016026962
1	0xba12222222228d8ba445958a75a0704d566bf2c8	1648944000	0.009198891
2	0x5a6a4d54456819380173272a5e8e9b9904bdf41b	1648857600	0.007091576
3	0xba12222222228d8ba445958a75a0704d566bf2c8	1649030400	0.006880386
4	0x7abe0ce388281d2acf297cb089caef3819b13448	1648857600	0.004113114
        --- 
```


## Datasets
The full [Ethereum Stablecoin Networks](https://chartalist.org/eth/StablecoinAnalysis.html) and [Ethereum Transaction Network](https://chartalist.org/eth/EthereumData.html) is publicly available on Chartalist.

# Citing
Please use the following BibTeX entry:
