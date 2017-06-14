% Hansen Zhao : zhaohs12@163.com
% 2016/12/2 : version 2.1
function [ indexTag, finalCentric, Distance ] = kMeans( dataSet,k,comd,varargin )

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
            [newTag,newC,newD] = kMeans(dataSet(~filter,:),k,comd,varargin{1},threshold);
            indexTag(~filter) = newTag;
            finalCentric = newC;
            Distance = newD;
            return;
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
    end
    
    Distance = sum(D);
    finalCentric = newCentricSet;
end

function [M] = sortMatrix(M_I)
    [~,I] = sort(mean(M_I,2));
    M = M_I(I,:);
end



