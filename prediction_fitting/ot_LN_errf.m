function err = ot_LN_errf(X)
sampling_rate =1000;%Hz
filter_length = 1;%seconds
X_filter = X(1:5);
X_nl = X(6:9);
[fr,Stim]= ot_target_loader();
Stim = (Stim-mean(Stim))';
%fr = downsample(fr,40);

linear_filter = ot_lin_filter(X_filter,sampling_rate);
nor_filter = linear_filter/abs(max(linear_filter));%normalize the filter by max value
% ntfilt = 1000;
% paddedStim = [zeros(ntfilt-1,1); Stim]; % pad early bins of stimulus with zero
% Xdsgn = hankel(paddedStim(1:end-ntfilt+1), Stim(end-ntfilt+1:end));%hankel matrix
% disp(num2str(randi([1,10])))
% filter_out =( Xdsgn)*nor_filter;  %this line should limit it to be casual
generator_signal = conv(Stim,flip(nor_filter));
filter_out = generator_signal(1:length(Stim));
LN_out = ot_nl_function(X_nl ,filter_out);

err = sum(abs((LN_out-fr').^2));%error
end