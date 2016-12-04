% function [ result ] = multiVar2CM( rawData,delay,dimension )
function [ X,header ] = multiVar2CM( raw,delay,D )
    [length,count] = size(raw);
    header = delay * (D - 1) + 1;
    newLength = length - header + 1;
    newCount = count * (count - 1)/2;
    X = zeros(newLength,newCount);
    mask = getMask(count);
    
    for m = 1:1:newLength
        tmp = raw(backward(m,delay,D),:);
        cm = corrcoef(tmp);
        X(m,:) = cm(mask);
    end
end

function [mask] = getMask(n)
    mask = zeros(n);
    for m = 1:1:n
        mask(m,m+1:n) = 1;
    end
    mask = logical(mask);
end

function x = backward(begin,step,length)
    x = begin : step : (begin + step * (length - 1));
end

