function [ slope,res,goodness,error ] = xy2MSS( XY,maxP )
    res = zeros(maxP+1,1);
    goodness = zeros(maxP,1);
    lag = min(100,round(size(XY,1)/3));
    
    for m = 1:1:maxP
        tmpMoment = msd(XY,lag,m);
        %plot(gca,(1:1:lag)',tmpMoment);
        %pause;
        %[object,gof] = fit((1:1:lag)',tmpMoment,'power1');
        [ab,error] = polyfit(log(1:1:lag)',log(tmpMoment),1);
        %plot(log(1:1:lag)',log(tmpMoment));
        %hold on;
        %plot(log(1:1:lag)',ab(1)*log(1:1:lag)'+ab(2));
        %hold off;
        %pause;
        res(m+1) = ab(1);
        goodness(m) = error.R(2);
    end
    %plot(gca,(0:1:maxP)',res);
    %pause;
    [slope,error] = polyfit((0:1:maxP)',res,1);
    slope = slope(1);
end

