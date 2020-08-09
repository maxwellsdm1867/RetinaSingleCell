close all
clear all
clc

chan = 1;

load('D:\RiekeLab\spikes\191217\hmm_r.mat')%load the hmm_r cell
eg2 = hmm_r{1,1};%extract all the epoches with g = 2
spk = eg2(chan).spikes;
stim = eg2(chan).stim;
[fr] = BinSpk1(0.04,spk,100);
spike_time_p = re_distrubuter(fr,25);
[fr1] = BinSpk1(0.04,spike_time_p,100);
sum(fr==fr1)



