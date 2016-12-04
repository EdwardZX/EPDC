function [ X,header ] = rcTimeDelaySet( raw,delay,D )
    [length,~] = size(raw);
    header = 1 + (D-1)*delay;
    count = length - header + 1;
    X = zeros(count,D);
    for m = 1:1:D
        X(:,m) = raw(1+(D-m)*delay:count+(D-m)*delay,:);
    end
end

