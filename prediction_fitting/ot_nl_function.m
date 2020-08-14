function LN_out = ot_nl_function(X,xarray)
%X is the paramenters for the sigmodal function
%xarray is the genrator signal

%   alpha * normcdf(beta .* xarray + gamma, 0, 1) + epsilon;
alpha = X(1);      % determines maximum
beta  = X(2);      % determines steepness
gamma = X(3);     % determines threshold/shoulder location
epsilon  =X(4);   % shifts all up or down
params = [alpha; beta; gamma; epsilon];
LN_out = (params(1) * normcdf(params(2) .* xarray + params(3), 0, 1) + params(4));
%keyboard
end