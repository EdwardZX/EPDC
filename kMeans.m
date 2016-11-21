% Hansen Zhao : zhaohs12@163.com
% 2016/10/22 : version 1.0
function [ result, finalCentric, iterationTime ] = kMeans( dataSet,k,comd,varargin )
% the first colomn of dataSet is data Tag
    [count,dimension] = size(dataSet);
    order = 0;
    switch comd
        case 'E'
            fun = @(x,y,p)pdist([x;y]);
        case 'V'
            fun = @(x,y,p)pdist([x;y],'cosine');
        case 'M'
            fun = @(x,y,p)pdist([x;y],'minkowski',p);
            order = varargin{1};
        case 'C'
            fun = @(x,y,p)pdist([x;y],'correlation');
    end
    centricSet = zeros(k,dimension - 1);
    newCentricSet = zeros(k,dimension - 1);
    
    uniqueLength = 0;
    classCell = cell(k,1);   %store vector in class
    indexVec = ones(k,1);    %store current num in each class
    iterationTime = 0;
    
    while k ~= uniqueLength    %make sure no same value generated
        randV = round(rand(k,1)*count);
        [uniqueLength,~] = size(unique(randV));
    end
    
    centricSet = dataSet(randV,2:dimension);
    
    for m = 1:1:k
        classCell{m} = zeros(count,dimension);
    end
    
    while (iterationTime < 3000)
        if iterationTime ~= 0
            centricSet = newCentricSet;
        end
        for m = 1:1:count
            index = getMinDisIndex(dataSet(m,2:dimension),centricSet,fun,order);
            classCell{index}(indexVec(index),:) = dataSet(m,:);
            indexVec(index) = indexVec(index) + 1;
        end
        for m = 1:1:k
            newCentricSet(m,:) = mean(classCell{m}(1:indexVec(m)-1,2:dimension));
        end
        
        if isequal(newCentricSet,centricSet)
            break;
        else
            iterationTime = iterationTime + 1;
            indexVec = ones(k,1);
            for m = 1:1:k
                classCell{m} = zeros(count,dimension);
            end    
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
        classCell{m}(indexVec(m):count,:)=[];
        result{m} = classCell{m};
    end
    
    finalCentric = newCentricSet; 
end


function [index] = getMinDisIndex(vec,centricSet,fun,p)
    [k,~] = size(centricSet);
    dis = zeros(k,1);
    for m=1:1:k
        dis(m) = fun(vec,centricSet(m,:),p);
    end
    [~,index]=min(dis);
end

