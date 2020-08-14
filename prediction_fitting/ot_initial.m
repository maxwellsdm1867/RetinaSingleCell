close all 
clear all
clc


%ot_LN_vis
[fr,Stim]= ot_target_loader();
Stim = (Stim-mean(Stim))';
sampling_rate = 1000;
sps = fr';
nsp = sum(fr);
ntfilt = 1000;
paddedStim = [zeros(ntfilt-1,1); Stim]; % pad early bins of stimulus with zero
Xdsgn = hankel(paddedStim(1:end-ntfilt+1), Stim(end-ntfilt+1:end));%hankel matrix
sta = (Xdsgn'*sps)/nsp;
% alpha * normcdf(beta .* xarray + gamma, 0, 1) + epsilon;
X_filter = ga(@ot_filter_errf,5);
linear_filter = ot_lin_filter(X_filter ,sampling_rate);


% alpha = params(1);      % determines maximum
% beta  = params(2);      % determines steepness
% gamma =params(3);     % determines threshold/shoulder location
% epsilon  =params(4);   % shifts all up or down
generator_signal = conv(linear_filter,Stim);
sta_out =( Xdsgn)*sta;

gm = generator_signal(1:length(Stim))/max(generator_signal(1:length(Stim)))*max(fr);
figure
subplot(2,1,1)
hold on
plot(sta)
plot(linear_filter)
hold off
legend('sta','fitted result')
subplot(2,1,2)
hold on 
plot(fr)
plot(gm)
hold off


%%
params(1) = -7;% determines maximum
params(2) = 0.008;% determines steepness
params(3) = 2;% determines threshold/shoulder location
params(4) = 7;% shifts all up or down
xarray = min(generator_signal):max(generator_signal);
sig = (params(1) * normcdf(params(2) .* xarray + params(3), 0, 1) + params(4));
filter_out  =gm; 
LN_out=(params(1) * normcdf(params(2) .*generator_signal + params(3), 0, 1) + params(4));
figure
subplot(4,1,1)
hold on
plot(sta)
plot(linear_filter)
hold off
legend('sta','fitted result')

subplot(4,1,2)
hold on 
plot(fr)
plot(gm)
hold off
subplot(4,1,3)
plot(xarray,sig)
subplot(4,1,4)
hold on
plot(fr)
plot(LN_out)
hold off