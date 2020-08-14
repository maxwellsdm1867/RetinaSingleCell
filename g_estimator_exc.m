load('D:\RiekeLab\spikes\191217\hmm_r.mat')%load the hmm_r cell
load('D:\RiekeLab\spikes\191217\peak_shape.mat')%load the peak shape
eg2 = hmm_r{1,1};%extract all the epoches with g = 2
%eg2 = hmm_r{1,2};  %use this if you want to extract g=10;
t = hmm_r{3,1};% time axis for tsmi curve
num_e = length(eg2);
rf = length(eg2);
stim_rate = 10000;
tar_rate = 20;%in Hz
nfbins = 25;
t_step = (0:(0.2*tar_rate-1))*(1/tar_rate*1000);
%%
close all
for i = 1:num_e
    [t2p, rpl,intensity,psth_p,psth_n,diff_pattern]=   step_info(eg2(i).spikes,eg2(i).stim,stim_rate, tar_rate);
    %[t2p, rpl,intensity] = g_estimator(eg2(i).spikes,eg2(i).stim,stim_rate, tar_rate);
    %visualization
    
    %%plotting
    figure('units','normalized','outerposition',[0 0 1 1])
    
    subplot(2,2,1)%tsmi
    plot(t,eg2(i).MI,'LineWidth',1.2)
    xlim([-2000 2000])
    
    subplot(2,2,2)%time to peak v.s. intensity
    hold on
    plot(t_step,psth_p)
    plot(t_step,psth_n)
    xlabel('time ')
    ylabel('psth')
    legend('light increment','light decrement')
    
    subplot(2,2,4)%ratio v.s. intensity
    %plot(lut2(1,:),lut2(2,:))
    scatter(diff_pattern,rpl)
    %     scatter(diff_pattern(diff_pattern>0),rpl((diff_pattern>0)))
    %     hold on
    %     scatter(diff_pattern(diff_pattern<0),rpl((diff_pattern<0)))
    %     hold off
    ylabel('end to max ratio')
    xlabel('intensity difference')
    
    subplot(2,2,3)%demo step response
    %     plot(t_step,psth)
    %     ylabel('average firing rate')
    histogram(rpl,0:0.1:1)
    [N,C] = hist(rpl,0:0.1:1);
    ylabel('counts')
    xlabel('end to max ratio')
    rf(i) = N(end)/N(1);
    ty = type(eg2(i).ID);
    if ty == 1
        typee = 'on ststain';
    elseif ty == 2
        typee ='on transiant';
    elseif ty == 3
        typee = 'off sustain';
    elseif ty == 4
        typee = 'off transiant';
    end
    typee
    title(['cell' num2str(eg2(i).ID) typee])
    saveas(gca,['cell' num2str(eg2(i).ID) '_e' num2str(i) '.jpg'])
    
end
x = rf(find(peak_shape==1));
y = rf(find(peak_shape==2));
[h,p]= ttest2(x,y)
