# EPDC
Empirical Particle Dynamic Classification

## What is EPDC?
+ EPDC is a stastical toolkit for identifying the motion partten of nano-particle or other things.
+ univariable or multivariable empirical data is taken into consideration to classify different motion pattern by k-means
+ EPDC is developed by Hansen Zhao and Yan He Group in Tsinghua University, China

## How to use EPDC

### step 1: Prepare your raw data
#### the first parameter for EPDC is xy position data in N-by-2 matrix, each rows represents an observation in a specific time
#### second param is rawData used to classification, in univariable, raw data should be a single colomn vector represents the polar angle or velocity or any other variable observed. The length of rawData should be equal to xy trace data.
#### third param is a comd to tell EPDC which method should be used.
+ 'uni' means univariable method
+ 'msd' means MSD test for nano-particle, the rawData should also be xy trajectory
+ 'autoc' means autocorrelation method, a univariate rawData vector should be given

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

#### the sixth param is a integer to tell EPDC how many times to perform k-means to get an optimize result with minimum total distance

#### the next param is a bool variate to tell EPDC whether show the graphic result after processing

#### the last param is optional. The value should be set between 0 to 1 to eliminate the outlier in k-means. Usually set as 0.2. Ignore this param will disable the outlier elimination.

### step 2: Calculation
#### use 
```
[ result ] = pNPa(xy,rawData,analysisMethod,param,comd,optTime, isSpeak, outlierRatio) 
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

### case example

#### processing

+ univariate-Euclidean distance for velocity
```
r = pNPa(xy,vel,'uni',[1,30,5,0],'E',30,0); % vector length 30, step interval 1, class number 5, repeat time 30, not speak after processing, ignore outlier elimination
```
+ MSD-Euclidean distance for MSD curve
```
r = pNPa(xy,xy,'msd',[1,30,5,0],'E',30,0,0.15); % vector length 30, class number 5, repeat time 30, not speak after processing, eliminate ouliear group smaller that 0.15*total number
```
+ autocorrelation-Euclidean distance for polar angle
```
r = pNPa(xy,polar,'autoc',[30,100,5,0],'E',30,0); % vector length 30, autocorrelation length 100, class number 5, repeat time 30, not speak after processing, ignore outlier elimination
```

#### analyze results
+ histogram of the class fraction
```
r.tagHist() %show histogram of the fraction of each group from the begining to the ending of the trace
r.tagHist(1000) %show histogram of the fraction of each group from 1000 to the ending of the trace
r.tagHist(1000,2000) %show histogram of the fraction of each group from 1000 to 2000 frame
```
+ cluster centers of each class
```
r.plotC() %plot cluster centers in a new figure with default color map
r.plotC(h) %plot cluster center in a h pointed figure with default color map, h is a figure handle
r.plotC(h,c) %plot cluster center in a h pointed figure with c given colormap
```
+ re-plot the results
```
r.plotTest(ha,bgData) %plot result in ha pointed axes. bgData is the curve that the scatter points follow, such as the velocity vector or polar angle vector, ha is a axes handle, or can be set as gca. this function can be used such as r.plotTest(gca,vel)
```
+ view the whole trace
```
g = PNPGUI(r)
g.show % a GUI will show-up for further operations
```
