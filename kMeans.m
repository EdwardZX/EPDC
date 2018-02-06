% Hansen Zhao : zhaohs12@163.com
% 2017/11/10 : version 3.1
function [ indexTag, finalCentric, Distance, probability ] = kMeans( dataSet,k,comd,varargin )

    if nargin <= 4
        isCheckMemberNum = false;
    else
        isCheckMemberNum = true;
        threshold = varargin{2};
    end
    
    [count,dimension] = size(dataSet);
    order = 0;
    switch comd
        case 'E'
            fun = @(c,d,p)pdist2(c,d,'squaredeuclidean');
        case 'V'
            fun = @(c,d,p)pdist2(c,d,'cosin');
        case 'M'
            order = varargin{1};
            fun = @(c,d,p)pdist2(c,d,'minkowski',p);
        case 'C'
            fun = @(c,d,p)pdist2(c,d,'correlation');
    end
    centricSet = zeros(k,dimension);
    newCentricSet = zeros(k,dimension);

    iterationTime = 1;
    
    centricSet = sortMatrix(dataSet(randsample(1:count,k),:));
    indexTag = zeros(count,1);

    
    while (iterationTime < 3000)
        D = fun(centricSet,dataSet,order);
        [d,indexTag] = min(D); indexTag = indexTag';
        probability = distance2prob(D);

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
    if isCheckMemberNum
        if threshold < 1
            threshold = round(threshold*count/k);
            fprintf(1,'Limit number: %d\n',threshold);
        end
        gcounts = zeros(k,1);
        for m = 1:1:k
            gcounts(m) = sum(indexTag==m);
        end
        [x,I] = min(gcounts);
        if x < threshold
            fprintf(2,'Group: %d has %d member, too short for %d average group count\n',...
                    I,x,threshold);
            filter = (indexTag==I);
            indexTag(filter) = nan;
            [newTag,newC,newD,prob] = kMeans(dataSet(~filter,:),k,comd,varargin{1},threshold);
            indexTag(~filter) = newTag;
            finalCentric = newC;
            Distance = newD;
            probability(:,~filter) = prob;
            probability(filter) = nan;
            return;
        end
    end
%         for m = 1:1:k
%             filter = (indexTag==m);
%             memberCount = sum(filter);
%             if memberCount < threshold
%                 fprintf(2,'Group: %d has %d member, too short for %d average group count\n',...
%                     m,memberCount,threshold);
%                 tmpTag = indexTag;
%                 tmpTag(filter) = nan;
%                 [newTag,newC,newD] = kMeans(dataSet(~filter,:),k,comd,varargin{1},threshold);
%                 tmpTag(~filter) = newTag;
%                 indexTag = tmpTag;
%                 finalCentric = newC;
%                 Distance = newD;
%                 return;
%             end
%         end

    
    Distance = sum(d);
    finalCentric = newCentricSet;
end

function [M] = sortMatrix(M_I)
    [~,I] = sort(mean(M_I,2));
    M = M_I(I,:);
end

function prob = distance2prob(D)
    % k-by-count Distance Matrix
    minDistance = min(D);
    k = size(D,1);
    weight = exp(-D./repmat(minDistance,k,1));
    weightSum = sum(weight);
    prob = weight./repmat(weightSum,k,1);  
end



