function [msdMatrix,header] = vecs2MSD(vecs,D)
    msdFun = @(A,B)mean(sum((A-B).^2,2));
    gIndexM = @(Index,D)bsxfun(@minus,(Index:-1:Index-D+1)',0:D);
    rawLength = size(vecs,1);
    dTime = 2 * D - 1;
    header = 2 * D;
    newLength = rawLength - dTime;
    msdMatrix = zeros(newLength,D);
    
    for m = 1:newLength
        IM = gIndexM(m + dTime,D);
        for n = 1:D
            msdMatrix(m,n) = msdFun(vecs(IM(:,1),:),vecs(IM(:,1+n),:));
        end
    end
end