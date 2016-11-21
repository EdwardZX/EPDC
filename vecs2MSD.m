function [msdMatrix] = vecs2MSD(vecs,dimension)
%vecs2MSD - Description
%
% Syntax: [msdMatrix] = vecs2MSD(vecs,dimension)
%
% Hansen Zhao : zhaohs12@163.com
% 2016/11/18 Tsinghua
% 
% construct MSD matrix for M vector for dimension 
% vecs - raw data of N-by-M matrix where N rows is time series data for each variable and every colomn is individual variable
% dimension - largest dimension of MSD calculation
% msdMatrix - return result (N-dimension*2+1)-by-(dimension+1) matrix
% for the first 1 ~ (dimension*2-1) points do not have enough data to calculate MSD
% colomn 1 is the time index
% colomn 2~(dimension+1) is MSD calculate with time step of 1,2,3...dimension
    [dataLenght,~] = size(vecs);
%    varNumPow2 = varNum^2;
    dTime2 = 2*dimension - 1;
%    newDataLength = dataLenght - varNumPow2;
    newDataLength = dataLenght - dTime2;
    msdMatrix = zeros(newDataLength,dimension+1);
    msdMatrix(:,1) = (1:1:newDataLength) + dTime2;

    distPow2 = zeros(dimension,1);
    h = waitbar(0,'ready for MSD calculation...');
    total = dimension * newDataLength;

    for tau = 1:1:dimension
        for timeIndex = 1:1:newDataLength
            head = timeIndex + dTime2;
            ender = head - tau;
            for m = 0:1:(dimension-1)
                %disp(strcat(num2str(head - m),'-',num2str(ender - m),'tau:',num2str(tau)));
                distPow2(m + 1) = pdist([vecs(head - m);vecs(ender - m)],'squaredeuclidean');
            end
            %disp(strcat('to msdMatrix[',num2str(timeIndex),',',num2str(tau + 1),'] with time: ',num2str(msdMatrix(timeIndex,1))));  
            msdMatrix(timeIndex,tau + 1) = mean(distPow2);
%            indecs = getIndecs(timeIndex + varNumPow2,tau,dimension);
%            calMatrix = vecs(indecs,:);
%            msdMatrix(timeIndex,tau + 1) = calMSD(calMatrix,dimension);
            waitbar(((tau - 1)*newDataLength + timeIndex)/total,h,'calculation processing...');
        end
    end
    waitbar(1.0,h,'done MSD calculation!');
    close(h);
end

%function [indecs] = getIndecs(headNum,tau,dimension)
%    indecs = headNum : -tau : headNum - (tau * dimension)
%end

%function [MSD] = calMSD(matrix,dimension)
%    distPow2 = zeros(dimension,1);
%    for n = 1:1:dimension
%        distPow2(n) = sum(abs(matrix(n+1,:) - matrix(n,:)).^2);
%    end
%    MSD = mean(distPow2);
%end