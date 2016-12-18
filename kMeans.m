% Hansen Zhao : zhaohs12@163.com
% 2016/12/2 : version 2.1
function [ indexTag, finalCentric, Distance ] = kMeans( dataSet,k,comd,varargin )

    [count,dimension] = size(dataSet);
    order = 0;
    switch comd
        case 'E'
            fun = @(c,d,p)pdist2(c,d,'squaredeuclidean','Smallest',1);
        case 'V'
            fun = @(c,d,p)pdist2(c,d,'cosin','Smallest',1);
        case 'M'
            order = varargin{1};
            fun = @(c,d,p)pdist2(c,d,'minkowski',p,'Smallest',1);
        case 'C'
            fun = @(c,d,p)pdist2(c,d,'correlation','Smallest',1);
    end
    centricSet = zeros(k,dimension);
    newCentricSet = zeros(k,dimension);

    iterationTime = 1;
    
    centricSet = sortMatrix(dataSet(randsample(1:count,k),:));
    indexTag = zeros(count,1);

    
    while (iterationTime < 3000)
        [D,indexTag] = fun(centricSet,dataSet,order);

        for m = 1:1:k
            newCentricSet(m,:) = mean(dataSet(indexTag==m,:));
        end
        
        if isequal(newCentricSet,centricSet)
            break;
        else
            iterationTime = iterationTime + 1;
            centricSet = sortMatrix(newCentricSet);   
        end      
    end
    
    Distance = sum(D);
    finalCentric = newCentricSet;
    
    %disp(strcat('Iteration Time: ',num2str(iterationTime)));
    %disp(strcat('sum of distance: ',num2str(Distance)));

end

function [M] = sortMatrix(M_I)
    [~,I] = sort(mean(M_I,2));
    M = M_I(I,:);
end



