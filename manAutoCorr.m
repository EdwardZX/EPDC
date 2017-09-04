function [ res ] = manAutoCorr(vec,maxLag)
    %manAutoCorr manually defined autocorrelation
    %   [ res ] = manAutoCorr(vec,maxLag)
    if maxLag > length(vec)
        disp('manAutoCorr: maxLag should smaller than vector length!')
        return;
    end
    res = zeros(maxLag+1,1);
    vec = vec(:); %make sure vec is a column vector
    for lag = 0:1:maxLag
        vec_raw = vec(1:(end-lag));
        vec_lag = vec((lag+1):end);
        %res(lag+1) = ( vec_raw' * vec_lag )/(vec_raw' * vec_raw);
        tmp = corrcoef(vec_raw,vec_lag);
        res(lag+1) = tmp(2);
    end
end

