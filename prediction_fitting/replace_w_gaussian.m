%replace each spike with an Gaussian distrubution
%where the width of the Gaussian is the 50 ms(+- 10 ms)
close all
clear all
clc

chan = 3;%epoch selection
load('D:\RiekeLab\spikes\191217\hmm_r.mat')%load the hmm_r cell
eg2 = hmm_r{1,2};%extract all the epoches with g = 10;
spk = eg2(chan).spikes;
stim = eg2(chan).stim;



%use the sample rate of 1 ms (1000 Hz) to make things simple;
Stim = downsample(stim,10);%
%bin the spike in the sametime bin

[fr] = BinSpk1(0.001,spk,100);
ntfilt = 1000;  % Try varying this, to see how performance changes!
Stim = Stim';
paddedStim = [zeros(ntfilt-1,1); Stim]; % pad early bins of stimulus with zero
Xdsgn = hankel(paddedStim(1:end-ntfilt+1), Stim(end-ntfilt+1:end));%hankel matrix
sps = fr';
nsp = sum(fr);
sta = (Xdsgn'*sps)/nsp;
%make a 50 ms Gaussian distrubution
g_x = -25:25;
g_y = gaussmf(g_x,[15 0]);

pst_fr = zeros(1,(length(g_x)+length(fr)+(length(g_x))));%51 ms padding for the Gaussian
for i = 1 : length(fr)
    
    temp_fr = zeros(1,(length(g_x)+length(fr)+(length(g_x))));
    temp_fr((51+i-25):(51+i+25)) = fr(i)*g_y;
    pst_fr =  pst_fr+temp_fr;
end
cv_fr = pst_fr(52:(52+100000-1));
sr_pair = [Stim'; cv_fr];

