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


### Get the count of each node consistuting a 3-node motif using the utility function in `innerCore.R`
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


### Get the centered 3-node motif counts of each node using the utility function in `utils.py`
```py
g = nx.erdos_renyi_graph(n=200, seed=1, p=2 / 200, directed=True)
>>> centerTriadCensus(g)
{'motif1': {2: 1, 4: 1, 5: 2, 6: 1, 8: 1, 9: 1, 11: 1, 12: 1, 14: 1, 16: 1, 17: 1, 19: 1, 22: 2, 24: 1, 28: 2, 29: 1, 31: 1, 35: 1, 36: 1, 39: 1, 41: 1, 45: 2, 47: 1, 48: 1, 51: 2, 53: 4, 54: 2, 59: 2, 60: 1, 61: 1, 62: 1, 64: 1, 65: 1, 67: 1, 70: 2, 71: 6, 72: 1, 76: 1, 77: 1, 82: 2, 83: 1, 84: 1, 89: 1, 90: 1, 94: 2, 96: 1, 97: 1, 100: 1, 102: 1, 103: 2, 108: 1, 109: 1, 111: 1, 112: 1, 113: 1, 115: 1, 119: 3, 121: 1, 123: 1, 124: 1, 125: 1, 127: 1, 130: 1, 132: 1, 135: 1, 139: 1, 141: 1, 142: 4, 143: 1, 145: 1, 146: 1, 149: 3, 151: 3, 156: 1, 159: 1, 161: 1, 163: 1, 164: 1, 165: 1, 166: 1, 167: 1, 168: 1, 169: 1, 175: 1, 177: 2, 178: 1, 179: 1, 182: 1, 183: 3, 185: 1, 187: 1, 189: 1, 190: 1, 191: 1, 192: 1, 195: 1, 196: 1, 197: 1, 199: 1}, 
'motif6': {}, 
'motif5buy': {74: 1, 10: 1, 187: 1, 31: 1, 52: 1, 158: 2, 175: 3}, 
'motif5sell': {185: 1, 17: 1, 15: 1, 53: 1, 65: 1, 192: 2, 96: 1, 161: 2}, 
'motif4': {0: 1, 1: 1, 6: 1, 7: 1, 15: 15, 19: 1, 21: 1, 23: 2, 26: 1, 27: 1, 30: 4, 31: 9, 32: 1, 33: 1, 34: 1, 38: 1, 39: 3, 40: 1, 44: 1, 46: 1, 49: 1, 50: 1, 52: 5, 54: 1, 55: 1, 56: 1, 57: 1, 58: 1, 59: 3, 63: 1, 67: 1, 69: 1, 70: 1, 71: 3, 73: 1, 74: 1, 76: 3, 79: 1, 80: 1, 81: 1, 85: 6, 87: 1, 92: 1, 93: 1, 95: 1, 98: 1, 99: 2, 102: 1, 104: 1, 105: 1, 106: 3, 107: 1, 110: 3, 114: 1, 116: 1, 117: 1, 118: 1, 120: 1, 126: 3, 133: 1, 134: 2, 135: 3, 136: 1, 137: 1, 138: 1, 140: 1, 141: 9, 143: 1, 144: 1, 147: 1, 148: 1, 149: 1, 151: 1, 152: 1, 153: 1, 154: 1, 155: 1, 157: 1, 159: 1, 160: 1, 166: 3, 171: 2, 172: 1, 173: 3, 174: 6, 175: 10, 176: 1, 180: 1, 183: 1, 184: 5, 186: 1, 187: 1, 185: 1, 188: 3, 189: 1, 194: 1}, 
'motif11': {}}
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
