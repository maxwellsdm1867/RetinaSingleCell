function [t2p, rpl,intensity,psth,diff_pattern]=  step_info(spike,stim,stim_rate, tar_rate)
%the script is used for extracting the revelant information for
%response of a 200 ms constant
%quantify (1) time to peak (2)the ratio of peaked and last bin of the
%step(3)scale with intensity level (4)psth
dwn_stim = downsample(stim,stim_rate/tar_rate);%downsample the stimulus
fr = BinSpk1(1/tar_rate,spike,length(stim)/stim_rate);%calculate the spike per bin, the bing rate is defined by tar_rate
step_size = (1/tar_rate); %time duration of the step after downsapling (in seconds)
hmm_size = 0.2;%the orginal step size of a constant
bins_per_step = hmm_size/step_size;% number of bins in one state
state_rate = 5;%the update rate of the HMM step
o_hmm = downsample(stim,stim_rate/state_rate);
t2p = [];% time to peak
rpl = [];%the ratio of peaked and last bin of the step
psth = [];%peri stimuli histogram 
diff_pattern =[];
intensity = [];%intensity of the steps
diff_int = diff([mean(o_hmm) o_hmm]); %the sequence of the intensity difference  
%extract infomation from indivusal steps

idx = 1:bins_per_step:length(dwn_stim);
cnt = 0;
temp_min = []; % response to min intensity
temp_max = [];% response to max intensity
psth = zeros(1,bins_per_step);

for i = 1:(length(dwn_stim)/bins_per_step )%ith step
    temp_fr = fr(idx(i):(idx(i)+bins_per_step-1));
    temp_stim = dwn_stim(idx(i):(idx(i)+bins_per_step-1));
    [M,I] = max(temp_fr);
    
    if M > mean(fr)*1.5% & temp_fr(end)~=0
        t2p  =[t2p I*step_size*1000];%time to peak in ms
        rpl =[rpl temp_fr(end)/M];
        intensity = [intensity temp_stim(1)];
        diff_pattern = [diff_pattern diff_int(i)];
    end
    psth = psth + temp_fr;
    
end
psth = psth/(length(dwn_stim)/bins_per_step );
end