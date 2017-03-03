function [ asym ] = xy2asym( vecs )
% From Huet, S., Karatekin, E., Tran, V. S., Fanget, I., Cribier, S., & Henry, J. P. (2006). 
% Analysis of Transient Behavior in Complex Trajectories: Application to Secretory Vesicle Dynamics. 
% Biophysical Journal, 91(9), 3542. 

[L,D] = size(vecs);
Rtensor = zeros(D,D); % gyration tensor

for m = 1:1:D
    for n = 1:1:D
        Xm = vecs(:,m);
        Xn = vecs(:,n);
        Rtensor(m,n) = 1/L * (sum(Xm .* Xn) + (1/L) * sum(Xm) * sum(Xn));
    end
end

[~,D] = eig(Rtensor);
R = diag(D);
subR = pdist(R);

asym = -log10(1 - 0.5 * (sum(subR .* subR) / sum(R)^2));

end

