function [ result ] = msd( vec,lag )
    [nr,~] = size(vec);
    result = zeros(lag,1);
    gIndexM = @(calLength,tau)bsxfun(@plus,(1:1:calLength)',[0,tau]);
    for m = 1:1:lag
        calLength = nr - m; %calculate length with tau = m;
        vecIndex = gIndexM(calLength,m);
        tmpM_L = vec(vecIndex(:,1),:);
        tmpM_H = vec(vecIndex(:,2),:);
        result(m) = mean(sum((tmpM_H - tmpM_L).^2,2));
    end
end

