function linear_filter = ot_lin_filter(X,sampling_rate)
numFilt = X(1);
tauR = X(2);
tauD = X(3);
tauP =X(4);
phi = X(5);
t_filter = ((1:sampling_rate) * 1/sampling_rate)';%the length of the filter, one second
linear_filter = ((((((t_filter./abs(tauR)) .^ numFilt) ./ (1 + ((t_filter./abs(tauR)) .^ numFilt))) ...
    .* exp(-((t_filter./tauD))) .* cos(((2.*pi.*t_filter) ./ tauP) + (2*pi*phi/360)))));
end