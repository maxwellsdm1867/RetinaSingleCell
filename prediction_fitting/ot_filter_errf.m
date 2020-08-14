function err = ot_filter_errf(X)
sampling_rate = 1000;
linear_filter = ot_lin_filter(X,sampling_rate);
load('D:\RiekeLab\modeling\200811\sta_g10.mat')
err = sum(abs(linear_filter-sta).^2);
end