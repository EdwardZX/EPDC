% Hansen Zhao : zhaohs12@163.com
% 2016/12/3 : version 2.0
% IN Tsinghua
% function [ result ] = pNPa(xy,rawData,analysisMethod,param,comd,optTime,isMute,varargin)
% xy : N-by-2 particle position in time series
% rawData : N-by-M raw data in time series
% analysisMethod:
% 'uni' for univariable time delay analysis
% 'msd' for msd analysis
% 'multi' for multivariable correlation analysis
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
% varargin{1} group number ratio limit in kmeans
function [ result ] = pNPa(xy,rawData,analysisMethod,param,comd,optTime,isSpeak,varargin)
    [count,~] = size(param);
    result = cell(count,1);
    if any(any(isnan(xy))) || any(any(isnan(rawData))) || any(any(isnan(param)))
        disp('ERROR: NaN value input!');
        return;
    end
    switch analysisMethod
        case 'uni'
            if size(rawData,2) > 1
                error('Too many variable input for univaribale analysis!');
                return;
            end
            aFun = @(raw,tau,D)rcTimeDelaySet(raw,tau,D);
        case 'msd'
            aFun = @(raw,tau,D)vecs2MSD(raw,D);
        case 'multi'
            aFun = @(raw,tau,D)multiVar2CM(raw,tau,D);
    end

    velocity = zeros(size(xy,1),1);
    velocity(2:end) = bsxfun(@(x,y)(sum((x-y).*(x-y),2)).^0.5,xy(2:end,:),xy(1:(end-1),:));
    
    for m=1:1:count
        [data,header] = aFun(rawData,param(m,1),param(m,2));
        if isempty(varargin)
          [I,C,~] = optKMeans(data,param(m,3),comd,param(m,4),optTime);
        else
          [I,C,~] = optKMeans(data,param(m,3),comd,param(m,4),optTime,varargin{1});
        end
        result{m} = NPMotionTest(analysisMethod,xy,data,I,header,C,velocity,param(m,1),param(m,2),param(m,3));
        disp(strcat(num2str(m),' / ',num2str(count),' has been done!'));
        if isSpeak
            if strcmp(analysisMethod,'uni')
                result{m}.plot(rawData);
            else
                result{m}.plot();
            end
        end
    end
    if count == 1
        result = result{1};
    end
    disp('All process has been done!');
end

