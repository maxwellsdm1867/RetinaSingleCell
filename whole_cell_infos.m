%this is where we do stats, for the whole cell voltage data
close all
clear all
tic
load('cabinet.mat')
raw_sorted = cabinet.hmm;
results = cell(2,size(cabinet.hmm,2));%spike and stimulus side by side
results(2,:)=raw_sorted(2,:);
for i = 1:length(raw_sorted)%g values
    tar = raw_sorted{1,i};
    for j= 1:length(tar)
        dwn_rsp = downsample(tar(j).epoch,40);
        stim = HMM_reborn2(tar(j).meta.correlationTime,tar(j).meta.seed, 10000,length(tar(j).epoch)/10000,5);
        dwn_stim = downsample(stim,40);
        [MI,MI_shuffled,t] = tsmi_clean(dwn_rsp,dwn_stim);
        figure
        plot(t,MI)
        xline(0)
        [MI_height, preloc] = max(MI(161:361));
        Mi_loc = t(161-1+preloc);
        temp1{1,i}(j).voltage = tar(j).epoch;
        temp1{1,i}(j).ph = MI_height;
        temp1{1,i}(j).pl = Mi_loc;
        temp1{1,i}(j).stim = stim;
        temp1{1,i}(j).dwnrsp = dwn_rsp;
        temp1{1,i}(j).MI = MI;
        temp1{1,i}(j).ID =tar(j).id;
    end
    
end
results(1,:) = temp1;
results{3,1}=t;
hmm_r = results;
save('hmm_r.mat','hmm_r')
toc
%%
close all
clear all
tic
load('cabinet.mat')
raw_sorted = cabinet.ou;
results = cell(2,size(cabinet.ou,2));%spike and stimulus side by side
results(2,:)=raw_sorted(2,:);
for i = 1:length(raw_sorted)%g values
    tar = raw_sorted{1,i};
    for j= 1:length(tar)
        dwn_rsp = downsample(tar(j).epoch,400);
        stim =  OU_reborn(tar(j).meta.correlationTime,tar(j).meta.seed, 10000,length(tar(j).epoch)/10000);
        dwn_stim = downsample(stim,400);
        [MI,MI_shuffled,t] = tsmi_clean(dwn_rsp,dwn_stim);
        figure
        plot(t,MI)
        xline(0)
        [MI_height, preloc] = max(MI(161:361));
        Mi_loc = t(161-1+preloc);
        temp1{1,i}(j).voltage = tar(j).epoch;
        temp1{1,i}(j).ph = MI_height;
        temp1{1,i}(j).pl = Mi_loc;
        temp1{1,i}(j).stim = stim;
        temp1{1,i}(j).dwnrsp = dwn_rsp;
        temp1{1,i}(j).MI = MI;
        temp1{1,i}(j).ID =tar(j).id;
    end
    
end
results(1,:) = temp1;
results{3,1}=t;
ou_r = results;
save('ou_r.mat','ou_r')

toc