# EPDC
Empirical Particle Dynamic Classification

## What is EPDC?
+ EPDC is a stastical toolkit for identifying the motion partten of nano-particle or other things.
+ univariable or multivariable empirical data is taken into consideration to classify different motion pattern by k-means
+ EPDC is developed by Hansen Zhao in Yan He Group in Tsinghua University, China

## How to use EPDC

### step 1: Prepare your raw data
#### the raw data essential for EPDC includes xy position data in N-by-2 matrix, each rows represents an observation in a specific time
#### second param is rawData used to classification, in univariable, raw data should be a single colomn vector represents the polar angle or velocity or any other variable observed. The length of rawData should be equal to xy trace data.
#### third param is a comd to tell EPDC which method should be used.
+ 'uni' means univariable method
+ 'msd' means MSD test for nano-particle, the rawData should also be xy
+ 'multi' means multivariable method, the empirical correlation of each variable is used for classification

#### next param is a M-by-4 matrix for batch process, each rows represents a processing for specific param
+ param(:,1) is timeDelay, useless in 'msd' method
+ param(:,2) is dimension
+ param(:,3) is k for k-Means
+ param(:,4) is order for Minkowski distance

#### the fifth param is also a char comd to tell EPDC which distance should be used
+ 'E' for Euclidean distance
+ 'V' for dot product
+ 'M' for Minkowski distance
+ 'C' for correlation
#### the last param is a integer to tell EPDC how many times to perform k-means to get an optimize result with minimum total distance

### step 2: Calculation
#### use 
```
[ result ] = pNPa(xy,rawData,analysisMethod,param,comd,varargin) 
```
in matlab comd console to perform the analysis
#### after the analyzation done, a graph will be automatically showed
#### result is a cell array for all analysis result in batch processing, result{n} represents the n th result

### step 3: View each point individually
#### use PNPGUI by comd 
```
g = PNPGUI(result{i});
g.show();
```

