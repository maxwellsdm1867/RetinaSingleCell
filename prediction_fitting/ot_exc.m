%the scipt is to have an external control or it will directly work with the
%variable in the work space to accomplish the looping sequence.
%the first way is to manulapte the file in certain directory

%ot_exc
close all
clear all
clc
load('D:\RiekeLab\spikes\191217\hmm_r.mat')%load the hmm_r cell
for g_val = 1:2
    if g_val == 1
        e = 44;
    elseif g_val ==2
        e = 25;
    end
    for k = 1:e%epoch
        chan = k%epoch selection
        eg2 = hmm_r{1,g_val};%extract all the epoches with g = 10;
        spk = eg2(chan).spikes;
        stim = eg2(chan).stim;
        
        
        %first replace each step with Gaussian
        %use the sample rate of 1 ms (1000 Hz) to make things simple;
        Stim = downsample(stim,10);%
        %bin the spike in the sametime bin
        
        [fr] = BinSpk1(0.001,spk,100);
        ntfilt = 1000;  % Try varying this, to see how performance changes!
        Stim = Stim';
        
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
        
        [x,fval,exitflag,output,population,score] = ot_LN_ga_main(sr_pair);
        ot_fun_vis(x)
        hmm_r{1,g_val}(chan).x = x;
    end
end




