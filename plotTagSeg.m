function [] = plotTagSeg(segStruct,c,varargin)
    x = 1:1:segStruct.length;
    y = zeros(segStruct.length,1);
    I = zeros(segStruct.length,1);
    L = length(segStruct.resCell);
    if isempty(varargin)
        offset = 0;
    else
        offset = varargin{1};
    end
    for m = 1:1:L
        data = segStruct.resCell{m};
        len = data(4)-data(3)+1;
        I(data(3):data(4)) = data(2);
        y(data(3):data(4)) = data(1);
        line((data(3):data(4))+offset,ones(len,1)*data(1),'Color',c(data(2),:),'LineWidth',3);
    end
end

