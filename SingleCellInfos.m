%this is where we do stats, for the spiking data
tic
raw_sorted = cabinet.hmm;
results = cell(2,size(cabinet.hmm,2));%spike and stimulus side by side
results(2,:)=raw_sorted(2,:);
for i = 1:length(raw_sorted)%g values
    tar = raw_sorted{1,i};
    for j= 1:length(tar)
        spikes = spike_detection(tar(j).epoch, 10000);%fix this later
        stim = HMM_reborn2(tar(j).meta.correlationTime,tar(j).meta.seed, 10000,length(tar(j).epoch)/10000,5);
        FR = BinSpk1(0.040,spikes,length(tar(j).epoch)/10000);
        dwn_stim = downsample(stim,400);
        [MI,MI_shuffled,t] = tsmi_clean(FR(1:end-1),dwn_stim);
        [MI_height, preloc] = max(MI(161:361));
        Mi_loc = t(161-1+preloc);
        temp1{1,i}(j).spikes = spikes;
        temp1{1,i}(j).ph = MI_height; 
        temp1{1,i}(j).pl = Mi_loc;
        temp1{1,i}(j).stim = stim;
        temp1{1,i}(j).FR = FR;
        temp1{1,i}(j).MI = MI;
        temp1{1,i}(j).ID =tar(j).id;
    end
    
end
results(1,:) = temp1;
results{3,1}=t;
toc

tic
raw_sorted = cabinet.ou;
results = cell(2,size(cabinet.ou,2));%spike and stimulus side by side
results(2,:)=raw_sorted(2,:);
for i = 1:length(raw_sorted)%g values
    tar = raw_sorted{1,i};
    for j= 1:length(tar)
        spikes = spike_detection(tar(j).epoch, 10000);%fix this later
        stim =  OU_reborn(tar(j).meta.correlationTime,tar(j).meta.seed, 10000,length(tar(j).epoch)/10000);
        FR = BinSpk1(0.040,spikes,length(tar(j).epoch)/10000);
        dwn_stim = downsample(stim,400);
        [MI,MI_shuffled,t] = tsmi_clean(FR(1:end-1),dwn_stim);
        [MI_height, preloc] = max(MI(161:361));
        Mi_loc = t(161-1+preloc);
        temp1{1,i}(j).spikes = spikes;
        temp1{1,i}(j).ph = MI_height; 
        temp1{1,i}(j).pl = Mi_loc;
        temp1{1,i}(j).stim = stim;
        temp1{1,i}(j).FR = FR;
        temp1{1,i}(j).MI = MI;
        temp1{1,i}(j).ID =tar(j).id;
    end
    
end
results(1,:) = temp1;
results{3,1}=t;
toc