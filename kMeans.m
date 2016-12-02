% Hansen Zhao : zhaohs12@163.com
% 2016/10/22 : version 1.0
function [ result, finalCentric, iterationTime ] = kMeans( dataSet,k,comd,varargin )
% the first colomn of dataSet is data Tag
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
    centricSet = zeros(k,dimension - 1);
    newCentricSet = zeros(k,dimension - 1);
    
%     uniqueLength = 0;
%    classCell = cell(k,1);   %store vector in class
%     indexVec = ones(k,1);    %store current num in each class
    iterationTime = 1;
    
%     while k ~= uniqueLength    %make sure no same value generated
%         randV = round(rand(k,1)*count);
%         [uniqueLength,~] = size(unique(randV));
%     end
%     
%     centricSet = dataSet(randV,2:dimension);
    centricSet = dataSet(randsample(1:count,k),2:dimension);
    indexTag = zeros(count,1);
%     for m = 1:1:k
%         classCell{m} = zeros(count,dimension);
%     end
    
    while (iterationTime < 3000)
        [~,indexTag] = fun(centricSet,dataSet(:,2:dimension),order);
%         if iterationTime ~= 0
%             centricSet = newCentricSet;
%         end
%         for m = 1:1:count
%             index = getMinDisIndex(dataSet(m,2:dimension),centricSet,fun,order);
%             classCell{index}(indexVec(index),:) = dataSet(m,:);
%             indexVec(index) = indexVec(index) + 1;
%         end
        for m = 1:1:k
            newCentricSet(m,:) = mean(dataSet(indexTag==m,2:dimension));
        end
%         
        if isequal(newCentricSet,centricSet)
            break;
        else
            iterationTime = iterationTime + 1;
            centricSet = newCentricSet;
%             indexVec = ones(k,1);
%             for m = 1:1:k
%                 classCell{m} = zeros(count,dimension);
%             end    
        end      
    end
    
    disp(strcat('Iteration Time: ',num2str(iterationTime)));
    disp(fun);
%     scatter([],[]);
%     hold on;
%     for m = 1:1:k
%         scatter(classCell{m}(1:indexVec(m)-1,2),classCell{m}(1:indexVec(m)-1,3));
%     end
%     
%     hold on;
%     scatter(newCentricSet(:,1),newCentricSet(:,2),'filled');
    
    result = cell(k,1);
    for m=1:1:k
%         classCell{m}(indexVec(m):count,:)=[];
        result{m} = dataSet(indexTag==m,1:dimension);
    end
    
    finalCentric = newCentricSet; 
end


% function [index] = getMinDisIndex(vec,centricSet,fun,p)
%     [k,~] = size(centricSet);
%     dis = zeros(k,1);
%     for m=1:1:k
%         dis(m) = fun(vec,centricSet(m,:),p);
%     end
%     [~,index]=min(dis);
% end


