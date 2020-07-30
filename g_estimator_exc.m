load('D:\RiekeLab\spikes\191217\hmm_r.mat')
eg2 = hmm_r{1,1};%extract all the epoches with g = 2
t = hmm_r{3,1};% time axis for tsmi curve
num_e = length(eg2);
stim_rate = 10000;
tar_rate = 50;%in Hz
nfbins = 100;
t_step = 0:
for i = 1:num_e
    [t2p, rpl,intensity,temp_min,temp_max] = g_estimator(eg2(i).spike,eg2(i).stim,stim_rate, tar_rate);
    lut1 = np_lut(intensity,t2p,nfbins );%time to peak v.s. intensity
    lut2 = np_lut(intensity,rpl,nfbins );%ratio v.s. intensity
    max_resp = mean(temp_max);
    min_resp = mean(temp_min);
    max_err = std(temp_max)/size(temp_max,1);
    min_err = std(temp_min)/size(temp_min,1);
    
    %visualization
    
    
    
end