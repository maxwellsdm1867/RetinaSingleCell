%ot_LN_vis
[x,fval,exitflag,output,population,score] = ga_hyberd(9,500);
%X = optimresults.x;
X=x;
sampling_rate =1000;%Hz
filter_length = 1;%seconds
X_filter = X(1:5);
X_nl = X(6:9);
myFolder =  'D:\RiekeLab\codes\fitting_temp_home';
sr_pair = ot_file_loader(myFolder);
Stim = sr_pair(1,:);
fr =  sr_pair(2,:);
Stim = (Stim-mean(Stim))';
% fr = downsample(fr,40);
linear_filter = ot_lin_filter(X_filter,sampling_rate);
nor_filter = linear_filter/abs(max(linear_filter));
generator_signal = conv(Stim,flip(nor_filter));
filter_out = generator_signal(1:length(Stim));
LN_out = ot_nl_function(X_nl ,filter_out);
params = X_nl;
xarray = min(generator_signal):max(generator_signal);
sig = (params(1) * normcdf(params(2) .* xarray + params(3), 0, 1) + params(4));
figure
subplot(4,1,1)
plot(nor_filter)
subplot(4,1,2)
plot(filter_out )
subplot(4,1,3)
plot(xarray,sig)
subplot(4,1,4)
hold on
plot(fr)
plot(LN_out)
hold off