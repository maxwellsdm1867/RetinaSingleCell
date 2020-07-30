load('D:\RiekeLab\spikes\191217\hmm_r.mat')%load the hmm_r cell
eg2 = hmm_r{1,1};%extract all the epoches with g = 2
%eg2 = hmm_r{1,2};  %use this if you want to extract g=10;
t = hmm_r{3,1};% time axis for tsmi curve
num_e = length(eg2);
stim_rate = 10000;
tar_rate = 100;%in Hz
nfbins = 25;
t_step = (0:(0.2*tar_rate-1))*(1/tar_rate*1000);
close all
for i = 1:num_e
    [t2p, rpl,intensity] = g_estimator(eg2(i).spikes,eg2(i).stim,stim_rate, tar_rate);
    %visualization
    figure('units','normalized','outerposition',[0 0 1 1])
    
    subplot(2,2,1)%tsmi
    plot(t,eg2(i).MI,'LineWidth',1.2)
    xlim([-2000 2000])
    
    subplot(2,2,2)%time to peak v.s. intensity
    histogram(t2p,t_step)
    xlabel('time to peak(ms)')
    ylabel('couts')
    
    subplot(2,2,4)%ratio v.s. intensity
    %plot(lut2(1,:),lut2(2,:))
    scatter(intensity,rpl)
    ylabel('end to max ratio')
    xlabel('Intensity')
    
    subplot(2,2,3)%demo step response
    histogram(rpl,0:0.1:1)
    ylabel('counts')
    xlabel('end to max ratio')
    saveas(gca,['cell' num2str(eg2(i).ID) 'e' num2str(i) '.jpg'])
end