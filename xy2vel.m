function [ velocity ] = xy2vel( XY)
    velocity = zeros(size(XY,1),1);
    velocity(2:end) = bsxfun(@(x,y)(sum((x-y).*(x-y),2)).^0.5,XY(2:end,:),XY(1:(end-1),:));
end

