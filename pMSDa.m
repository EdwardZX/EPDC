function [result] = pMSDa(rawData,param,comd)
%pMSDa - Description
%
% Syntax: [result] = pMSDa(rawData,param,comd)
%
% rawData : rawData with N-by-M matrix,each row is an observation in specific time
% each colomn is a measurement of a variable
% dimension can be a vector with different value, each value will process a test
% param(x,1): dimension
% param(x,2): k
% param(x,3): order
% comd: distance defined by
% 'E' for Euclidean distance
% 'V' for dot product
% 'M' for Minkowski distance
% 'C' for correlation

    [count,~] = size(param);
    result = cell(count,1);
    [leng,~] = size(rawData);
    vel = zeros(leng,1);
    
    for m = 2:1:leng
        vel(m) = pdist([rawData(m-1,:);rawData(m,:)]);
    end
    
    for m = 1:1:count
        msdMat = vecs2MSD(rawData,param(m));
        [rs,centricSet,iT] = kMeans(msdMat,param(m,2),comd,param(m,3));
        for n = 1:1:param(m,2)
            rs{n} = [rs{n}(:,1),vel(rs{n}(:,1),1),rs{n}(:,2:param(m,1)+1)];
        end
        result{m} = NPMotionTest(iT,param(m,1),param(m,1),param(m,2),rawData,rs,centricSet);
        disp(strcat(num2str(m),' / ',num2str(count),' has been done!'));
        figure;
        result{m}.plotTest();
    end
    
end