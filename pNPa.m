% Hansen Zhao : zhaohs12@163.com
% 2016/10/22 : version 1.0
% IN Tsinghua
function [ result ] = pNPa(rawData,param,comd)
% rawData : N-by-1 raw data in time series
% param : M-by-4 param to test 
% param(x,1): timeDelay
% param(x,2): dimension
% param(x,3): k
% param(x,4): order
% comd: distance defined by
% 'E' for Euclidean distance
% 'V' for dot product
% 'M' for Minkowski distance
% 'C' for correlation

    [count,~] = size(param);
    result = cell(count,1);
    for m=1:1:count
        data = rcTimeDelaySet(rawData,param(m,1),param(m,2));
        [rs,centricSet,iT] = kMeans(data,param(m,3),comd,param(m,4));
        result{m} = NPMotionTest(iT,param(m,1),param(m,2),param(m,3),rawData,rs,centricSet);
        disp(strcat(num2str(m),' / ',num2str(count),' has been done!'));
        figure;
        result{m}.plotTest();
    end
    disp('All process has been done!');
end

