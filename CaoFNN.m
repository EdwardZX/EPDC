function [E1,E2] = CaoFNN(vec,tau,maxD)

    E = zeros(maxD + 1,1);
    Es = zeros(maxD + 1,1);
    E1 = zeros(maxD,1);
    E2 = zeros(maxD,1);
    
    curRS = rcTimeDelaySet(vec,tau,1); %current reconstructed space;
    
    for m = 1:1:(maxD+1)
        newRS = rcTimeDelaySet(vec,tau,m+1); %d+1 spacace
        
        curRS(1:tau,:) = [];
        indices = NN(curRS); %get relative map index of nearest neighbor i to n(i,d)
        %abDict = [(1+m*tau):1:length(vec),indices + (m*tau)];
        Edist1 = CaoMetric(curRS,curRS(indices,:)); %R(d)
        Edist2 = CaoMetric(newRS,newRS(indices,:)); %R(d+1);
        E(m) = mean(Edist2./Edist1); 
                
        Es(m) = mean(abs(vec(1:1:length(indices)) - vec(indices)));
        
        curRS = newRS;
    end
    
    for m =1:1:maxD
        E1(m) = E(m+1)/E(m);
        E2(m) = Es(m+1)/Es(m);
    end
    
    plot(1:1:maxD,E1,'LineWidth',1,'DisplayName','E1');
    hold on;
    plot(1:1:maxD,E2,'LineWidth',1,'DisplayName','E2');
end


function I = NN(dataMat)
    D = pdist2(dataMat,dataMat); %D(i,j) is distance of vec(i) and vec(j)
    D(D==0) = inf; %ignore overlap point and self nearest
    [~,I] = min(D,[],2);
end

function dist = CaoMetric(vec1,vec2)
    dist = max(abs(vec1-vec2),[],2);
end

function Es = EStar(vec,tau,d,mapIndex)
% Estar = mean(X(i-d*tau) - Xn(i,d)-d*tau)
    i_index = (1+d*tau):1:length(vec); %get absolute index of i
    mapIndex = mapIndex + d * tau; % get absolut index map of i to n(i,d)
    nid_index = i_index(mapIndex);
    Es = mean(abs(vec(i_index - tau * d) - vec(nid_index - tau * d)));  
end


