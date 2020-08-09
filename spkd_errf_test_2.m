close all
clear all
clc

chan = 3;%channel selection 

load('D:\RiekeLab\spikes\191217\hmm_r.mat')%load the hmm_r cell
eg2 = hmm_r{1,2};%extract all the epoches with g = 2
spk = eg2(chan).spikes;%spike time 
stim = eg2(chan).stim; %stimuli before downsample 
[fr] = BinSpk1(0.04,spk,100);%firing rate binned every 40 ms 
spike_time_p = re_distrubuter(fr,25); % re_disturbute the spike 
[fr1] = BinSpk1(0.04,spike_time_p,100);%check the the rebin spike 

ntfilt = 25;  %length of the paddle 
D_stim = (downsample(stim,400))';
post_stim = D_stim-mean(D_stim);
paddedStim = [zeros(ntfilt-1,1); post_stim]; % pad early bins of stimulus with zero
Xdsgn = hankel(paddedStim(1:end-ntfilt+1), post_stim(end-ntfilt+1:end));%hankel matrix
sps = fr';
nsp = sum(fr);
sta = (Xdsgn'*sps)/nsp;
figure
subplot(1,2,1)
plot(sta)
subplot(1,2,2)
plot(eg2(chan).MI)
sta_out =( Xdsgn)*sta;
X = ga(@filter_errf,6);
nor_h = (sta-mean(sta));
figure
hold on
plot(nor_h)
plot(lin_filter(X))
hold off
lut = np_lut(sta_out,fr',25 );
Y = ga(@ link_fn_errf_s,4);
 [LN_out, linear_filter]= LN_parameter([X Y]);