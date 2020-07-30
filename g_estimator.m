function [t2p, rpl,intensity]=  g_estimator(spike,stim,stim_rate, tar_rate)
%the script is used for estimation of the g values using the response to a
%response of a 200 ms constant
%quantify (1) time to peak (2)the ratio of peaked and last bin of the
%step(3)scale with intensity level (4)demo epochs(highest and lowest intensity) with error bar
dwn_stim = downsample(stim,stim_rate/tar_rate);%downsample the stimulus
fr = BinSpk1(1/tar_rate,spike,length(stim)/stim_rate);%calculate the spike per bin, the bing rate is defined by tar_rate
step_size = (1/tar_rate); %time duration of the step after downsapling (in seconds)
hmm_size = 0.2;%the orginal step size of a constant
bins_per_step = hmm_size/step_size;% number of bins in one state

t2p = [];% time to peak
rpl = [];%the ratio of peaked and last bin of the step
intensity = [];%intensity of the steps
%extract infomation from indivusal steps

idx = 1:bins_per_step:length(dwn_stim);
cnt = 0;
temp_min = []; % response to min intensity
temp_max = [];% response to max intensity
for i = 1:(length(dwn_stim)/bins_per_step )%ith step
    %keyboard
    temp_fr = fr(idx(i):(idx(i)+9));
    temp_stim = dwn_stim(idx(i):(idx(i)+9));
    [M,I] = max(temp_fr);
    if M ~= 0% & temp_fr(end)~=0
        t2p  =[t2p I*step_size*1000];%time to peak in ms
        rpl =[rpl temp_fr(end)/M];
        intensity = [intensity temp_stim(1)];
      I
        %extract the demo firing rate
         
%         if abs(intensity - min(dwn_stim))<0.001
%             i
%             temp_min = [temp_min;temp_fr];
%         elseif abs(intensity - max(dwn_stim))<0.01
%             i
%             temp_max =  [temp_max;temp_fr];
%         end
%         
    end
    
    
end

end