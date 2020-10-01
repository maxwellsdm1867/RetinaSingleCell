%whole cell quick look and data summary(whole cell)
%this code is called experiment summary, the purpose is to obtain a first
%glance at the data, including the information profile
%designate a dir and it will read everything in the dir
%for the whole cell data, need to also know which one is exc and inh
close all
clear all
clc
%cell type labeling
type{1,1}= 'cone bipolar';
type{1,2}= 'amarcine';
type{1,3}= 'amarcine';
type{1,4}= 'cone bipolar';
type{1,5}= 'cone bipolar';
type{1,6}= 'rod bipolar';
type{1,7}= 'cone bipolar';
type{1,8}= 'rod bipolar';
type{1,9}= 'amarcine';
%load the data
data_dir = 'D:\RiekeLab\whole_cell\whole_cell_temp';
cd(data_dir)
files = dir('*.mat');
comp = cell(2,length(files));
for i=1:length(files)
    eval(['load ' files(i).name ]);
    comp{1,i} = epochs;
    comp{2,i} = files(i).name;
end
hmmg=[];
oug=[];
mega = comp;
%to check how many g values are there in the Hmm and OU
for i=1:length(mega)
    temp = mega{1,i};
    es =length(temp);
    for j=1:es%add in noise step data later
        if strcmp(temp(j).meta.displayName,'HMM Single')
            hmmg =[hmmg temp(j).meta.correlationTime];
        elseif strcmp(temp(j).meta.displayName,'OU Single')
            oug =[oug temp(j).meta.correlationTime];
        end
    end
end
hmmg_u = unique(hmmg);%how many parameters of HMM
oug_u = unique(oug);%how many parameters of OU

%% cabinet file, sort by conditions
if isempty(hmmg_u)~= 1
    cabinet.hmm=cell(2,length(hmmg_u));
    for k = 1:length(hmmg_u)
        target = hmmg_u(k);
        cabinet.hmm{2,k} = target;
        for i=1:length(mega)%cell id there is an error here
            temp = mega{1,i};
            es =length(temp);
            for j =1:es%all the epochs
                if strcmp(temp(j).meta.displayName,'HMM Single') & temp(j).meta.correlationTime==target
                    temp(j).id=i;
                    cabinet.hmm{1,k} =  [cabinet.hmm{1,k}; temp(j)];
                end
            end
        end
    end
else
    cabinet.hmm = {};
end
if  isempty(oug_u)~= 1
    cabinet.ou=cell(2,length(oug_u));
    
    for k = 1:length(oug_u)
        target = oug_u(k);
        cabinet.ou{2,k} = target;
        for i=1:length(mega)%cell id
            temp = mega{1,i};
            es =length(temp);
            for j =1:es%all the epochs
                if strcmp(temp(j).meta.displayName,'OU Single') & temp(j).meta.correlationTime==target
                    temp(j).id=i;%i th cell
                    cabinet.ou{1,k} =  [cabinet.ou{1,k}; temp(j)];
                end
            end
        end
    end
else
    cabinet.ou ={};
end
%% primary analysis
close all
BinningSamplingRate = 40;
states = 20;
if  isempty(hmmg_u)~= 1
    tic
    raw_sorted = cabinet.hmm;
    results = cell(2,size(cabinet.hmm,2));%spike and stimulus side by side
    results(2,:)=raw_sorted(2,:);
    for i = 1:length(raw_sorted)%g values
        tar = raw_sorted{1,i};
        for j= 1:length(tar)
            sort_resp = sort_state(states,tar(j).epoch);
            dwn_rsp = downsample(sort_resp,400);
            stim = HMM_reborn2(tar(j).meta.correlationTime,tar(j).meta.seed, 10000,length(tar(j).epoch)/10000,5);
            dwn_stim = downsample(stim,400);
            [MI,t]= only_timeshift(dwn_stim,dwn_rsp,BinningSamplingRate);
            
            %             figure
            %             plot(t,MI)
            %             xline(0)
            temp1{1,i}(j).voltage = tar(j).epoch;
            temp1{1,i}(j).stim = stim;
            temp1{1,i}(j).dwnrsp = dwn_rsp;
            temp1{1,i}(j).MI = MI;
            temp1{1,i}(j).ID =tar(j).id;
        end
        
    end
    results(1,:) = temp1;
    results{3,1}=t;
    toc
end



