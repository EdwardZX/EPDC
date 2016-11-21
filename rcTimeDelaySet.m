function [ Nset ] = rcTimeDelaySet( set,delay,d )
    [length,~] = size(set);
    count = length - (d-1)*delay;
    Nset = zeros(count,d + 1);
    for m = 1:1:d
        Nset(:,m + 1) = set(1+(d-m)*delay:count+(d-m)*delay,:);
    end
    Nset(:,1) = 1+(d-1)*delay : 1 : count+(d-1)*delay;
end

