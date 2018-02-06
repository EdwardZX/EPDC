function [ res ] = plotNMI(vec,maxT,nbins)
    precious = range(vec)/nbins;
    res = zeros(maxT+1,1);
    vec = round((vec./precious)) .* precious; 
    parfor m = 0:1:maxT
        newLength = length(vec) - m;
        res(m+1) = nmi(vec(1:newLength)',vec((1+m):end)');
        %fprintf(1,'%d has done\n',m);
    end
    plot(0:1:maxT,res,'LineWidth',1);
    xlabel('Time Delay');
    ylabel('Normalize Mutual Information');
    [~,loc] = findpeaks(-res);
    if ~isempty(loc)
        hold on;
        scatter(loc(1)-1,res(loc(1)),'filled');
    end
end

