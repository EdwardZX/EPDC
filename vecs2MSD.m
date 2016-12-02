function [msdMatrix] = vecs2MSD(vecs,dimension)
    msdFun = @(A,B)mean(dot((A-B),(A-B),2));
    gIndexM = @(Index,D)bsxfun(@minus,(Index:-1:Index-D+1)',0:D);
    rawLength = size(vecs,1);
    dTime = 2 * dimension - 1;
    newLength = rawLength - dTime;
    msdMatrix = zeros(newLength,dimension + 1);
    
    msdMatrix(:,1) = (dTime + 1):1:rawLength;
    for m = 1:newLength
        IM = gIndexM(m + dTime,dimension);
        for n = 1:dimension
            msdMatrix(m,1+n) = msdFun(vecs(IM(:,1)),vecs(IM(:,1+n)));
        end
    end
end