import pandas as pd
import math

# Computes the expansion and decay measure of each day from the day denoted by
# UNIX timestamp start + interval days to the end day denoted by UNIX timestamp and saves
# the results to a .csv file in the form expansion_decay_1661385600_to_1661817600_i=3.csv
# where 1661385600_to_1661817600 denotes the start to end range and i=3 denotes the i value.
# The method expects the working directory to contain the addresses of each day in the form
# innerCore_025_1661126400 where innerCore_025_ is a prefix for identification and 1661126400
# as the UNIX timestamp of the day with a column of nodes.
#
# @param interval Refers to the variable i in the definition of expansion and decay measure
# @param start The UNIX timestamp of the first day
# @param end The UNIX timestamp of the last day (inclusive)
# @param filePrefix The prefix of each file to be parsed containing the nodes of the day
# @param colName Name of the nodes column in each file
def computeExpansionDecay(interval, start, end, filePrefix, colName):
    innerCore = {}

    currDay = start

    while currDay != end + 86400:
        df = pd.read_csv(filePrefix + str(currDay) + ".csv")
        addresses = df[colName].to_numpy()
        innerCore[currDay] = set()

        # populate dictionary with set of addresses in each day
        for addr in addresses:
            innerCore[currDay].add(addr)
        currDay += 86400

    currDay = start + (interval * 86400)  # t
    intervalStart = start
    timestamp = []
    expansionMeasure = []
    decayMeasure = []
    while currDay != end + 86400:
        unionSet = set()
        for i in range(int(intervalStart / 86400), int(currDay / 86400)):
            unionSet = unionSet.union(innerCore[i * 86400])

        expand = innerCore[currDay].difference(unionSet)
        decay = unionSet.difference(innerCore[currDay])
        timestamp.append(currDay)
        expansionMeasure.append(len(expand) / len(unionSet))
        decayMeasure.append(len(decay) / len(unionSet))
        currDay += 86400
        intervalStart += 86400

    dict = {"timestamp": timestamp, "expansion": expansionMeasure, "decay": decayMeasure}
    df = pd.DataFrame(dict)
    df.to_csv("expansion_decay_" + str(timestamp[0]) + "_to_" + str(end) + "_i=" + str(
        interval) + ".csv")


# Computes the NF-IAF score of each address of each day from UNIX timestamp start to end
# (inclusive) of each motif type and saves the result in descending score order to a .csv
# file for each motif type in the form nfiaf_1648857600_to_1667088000_motif4.csv where
# 1648857600_to_1667088000 denotes the start to end range and motif4 denotes the type of
# motif that all scores are of.  The method expects the working directory to contain the
# motif counts of each day in the form of a .csv file named 1648857600_motif3 where 1648857600
# denotes the UNIX timestamp of the day and motif3 denotes the motif type with a column of
# addresses and a column of occurrences in the particular motif type of the day.
#
# @param start The UNIX timestamp of the first day
# @param end The UNIX timestamp of the last day (inclusive)
# @param motifs A list of motif types that serve as the suffix of each .csv file to be parsed
#               containing the motif counts
# @param filePrefix The prefix of each file to be parsed containing the motif counts of the day
# @param addrColName Name of the address column name of each file
# @param occurColName Name of the column contianing the motif counts of each file
def computeNFIAF(start, end, motifs, filePrefix, addrColName, occurColName):
    dict = {}

    # fill each motif set with unique motif center addresses from all days of that motif type
    for motif in motifs:
        dict[motif] = set()
        currDay = start
        while currDay != end + 86400:
            df = pd.read_csv(filePrefix + str(currDay) + "_" + motif + ".csv")
            addresses = df[addrColName].to_numpy()
            for addr in addresses:
                dict[motif].add(addr)
            currDay += 86400

    for motif in motifs:
        addressCol = []
        timestampCol = []
        nfiafCol = []

        # for every unique center address
        for addr in dict[motif]:
            currDay = start
            occurrences = 0

            # compute iaf of each address each day
            while currDay != end + 86400:
                df = pd.read_csv(filePrefix + str(currDay) + "_" + motif + ".csv")
                if addr in df[addrColName].values:
                    occurrences += 1
                currDay += 86400

            iaf = math.log10(((end - start) / 86400 + 1) / occurrences)

            currDay = start
            totalAddr = 0
            occurrences = 0

            # compute nfiaf for each address each day
            while currDay != end + 86400:
                df = pd.read_csv(filePrefix + str(currDay) + "_" + motif + ".csv")
                addresses = df[addrColName].to_numpy()
                occur = df[occurColName].to_numpy()
                for i in range(0, len(addresses)):
                    totalAddr += occur[i]
                    if addresses[i] == addr:
                        occurrences = occur[i]

                addressCol.append(addr)
                timestampCol.append(currDay)
                nfiafCol.append(occurrences / totalAddr * iaf)
                currDay += 86400

        csv_dict = {'address': addressCol, 'timestamp': timestampCol, 'nfiaf': nfiafCol}
        df = pd.DataFrame(csv_dict)
        df = df.sort_values(by=['nfiaf'], ascending=False)
        df = df.reset_index(drop=True)
        df.to_csv("nfiaf_" + str(start) + "_to_" + str(end) + "_" + motif + ".csv")
        
