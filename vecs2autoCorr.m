function [mat,header] = vecs2autoCorr( vecs,D,maxLag )
    if D <= maxLag
        error('Dimension: %d should larger than maxLag: %d!\n',D,maxLag);
    end
    header = D;
    newLength = size(vecs,1) - D + 1;
    mat = zeros(newLength,maxLag+1);
    for m = 1:1:newLength
        mat(m,:) = manAutoCorr(vecs(m:(D+m-1)),maxLag);
    end  
end