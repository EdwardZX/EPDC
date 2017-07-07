function [indexTag,C,D] = optKMeans(raw,k,comd,p,optTime,varargin)
    %% function [indexTag,C,D] = optKMeans(raw,k,comd,p,optTime,varargin)
    disp('Optimization begin...');
    disp(strcat('Total trial: ',num2str(optTime)));
    if isempty(varargin)
        [indexTag,C,D] = kMeans(raw,k,comd,p);
    else
        [indexTag,C,D] = kMeans(raw,k,comd,p,varargin{1});
    end
    if optTime > 1
        for m = 2:1:optTime
            if isempty(varargin)
                [I,c,d] = kMeans(raw,k,comd,p);
            else
                [I,c,d] = kMeans(raw,k,comd,p,varargin{1});
            end
            if(d<D)
                indexTag = I;
                C = c;
                D = d;
            end
        end
        disp(strcat('The optimized distance is: ',num2str(D)));
    end    
end

