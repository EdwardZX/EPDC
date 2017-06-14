function [ msdVec,mssVec,alpha,diffuseCoef,slope ] = MSA( XY,D,varargin )
% function [ msdVec,mssVec,alpha,diffuseCoef,slope ] = MSA( XY,D )
% only for 2D
    if nargin > 2
        isPlot = varargin{1};
    else
        isPlot = 1;
    end
    [L,~] = size(XY);
    newL = L-D+1;
    d = round(D/2);
    
    msdVec = zeros(newL,d+1);
    mssVec = zeros(newL,7);
    
    if isPlot
        h = waitbar(0,'Calculating MSD and MSS,please wait...');
    end
    for m = 1:1:newL
        tmpXY = XY(m:(m+D-1),:);
        msdVec(m,2:end) = msd(tmpXY,d);
        [~,mssVec(m,:),~,~] = xy2MSS(tmpXY,6);
%         if any(mssVec(m,:)<0)
%             disp('ss')
%         end
        if isPlot
            waitbar(m * 0.5/newL,h);
        end
    end
    
    alpha = zeros(newL,1);
    slope = zeros(newL,1);
    diffuseCoef = zeros(newL,1);
    if isPlot
        waitbar(0.5,h,'Processing,please wait...');
    end
    for m = 1:1:newL
        tmp = polyfit(log(1:1:d),log(msdVec(m,2:end)),1);
        alpha(m) = tmp(1);
        diffuseCoef(m) = exp(tmp(2)) * 0.25;
        tmp = polyfit(0:1:6,mssVec(m,:),1);
        slope(m) = tmp(1);
        if isPlot
            waitbar(0.5 + 0.5 * m/newL,h);
        end
    end
    if isPlot
        close(h);
    end
    
    
    if isPlot
        subplot(1,2,1);
        scatter3(alpha,slope,(1:1:newL)+D-1,15,'filled');
        xlabel('Alpha of MSD');
        ylabel('S-MSS');
        zlabel('Time Index'); 
        box on;
        grid on;

        subplot(1,2,2);
        scatter3(alpha,slope,diffuseCoef,15,'filled');
        xlabel('Alpha of MSD');
        ylabel('S-MSS');
        zlabel('Diffusion Coefficient'); 
        box on;
        grid on;
    end
end

