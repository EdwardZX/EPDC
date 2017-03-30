function [ res ] = HenonAttractor( length,initValue,ab,split )
    if nargin < 4
        split = 200;
    end
    
    if nargin < 3
        ab = [1.4;0.3];
    end
    
    if nargin < 2
        initValue = [0,0];
    end
    
    if nargin < 1
        length = 1000;
    end
    
    res = zeros(length,2);
    res(1,:) = initValue;
    
    for m = 2:1:length
        res(m,2) = res(m-1,1); %y(t+1) = x(t)
        res(m,1) = 1 - ab(1) * res(m-1,1)^2 + ab(2) * res(m-1,2); %x(t+1) = 1 - a*x(t)^2 + b * y(t);
    end
    
    res = res((split+1):end,:);
end

