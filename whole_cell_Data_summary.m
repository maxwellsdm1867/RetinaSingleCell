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
fig_dir = 'D:\RiekeLab\figures\201002';
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
            dwn_rsp = downsample(sort_resp,100);
            %dwn_rsp = downsample(tar(j).epoch,400);
            stim = HMM_reborn2(tar(j).meta.correlationTime,tar(j).meta.seed, 10000,length(tar(j).epoch)/10000,5);
            dwn_stim = downsample(stim,100);
            [MI,t]= only_timeshift(dwn_stim,dwn_rsp,BinningSamplingRate);
            %[MI,MI_shuffled,t] = tsmi_clean(dwn_rsp,dwn_stim);
            
            figure
            plot(t,MI)
            xline(0)
            title(['i_' num2str(i) '_j_' num2str(j) ])
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
hmm_r = results;
%%
close all
%seperate the inh and exc and plot them out, zero is a nice sepreation
%point, just plot them side by side
for k = 1:length(files)
    figure
    hold on
    for i = 1:2
        temp = results{1,i};
        for  j = 1:length(temp)
            if temp(j).ID == k
                plot(temp(j).voltage)
                xlim([0 6000])
            end
        end
    end
    hold off
end
%%
close all
%hmm only
for cell_id = 1:length(type)
    figure('units','normalized','outerposition',[0 0 1 1])
    
    
    sk = [];%indicate the hmm 
    parm = [];
    mk = [];%indicate the current
    %get the distinguish colors
    for hmm_i = 1:size(hmm_r,2)%get the color scheme
        tempz = hmm_r{1,hmm_i};
        for k = 1:length(tempz)%one g-value
            if tempz(k).ID == cell_id
                sk = [sk 0];%0 is hmm
                parm = [parm hmm_r{2,hmm_i} ];
            end
        end
    end
     for hmm_i = 1:size(hmm_r,2)%get the color scheme
        tempz = hmm_r{1,hmm_i};
        for k = 1:length(tempz)%one g-value
            if tempz(k).ID == cell_id & min(tempz(k).voltage) >0
                mk = [mk 0];%0 inh
            elseif tempz(k).ID == cell_id & min(tempz(k).voltage) <0
                mk = [mk 1];
            end
        end
    end
    n_colors = sum(sk==0);
    colors = distinguishable_colors(n_colors);
    ci = 0;
    
    subplot(1,2,1)
    hold on
    %plot the MI curve cell by cell
    for hmm_i = 1:size(hmm_r,2)
        tempz = hmm_r{1,hmm_i};
        for k = 1:length(tempz)%one g-value
            if tempz(k).ID == cell_id
                ci = ci+1;
                plot(hmm_r{3,1},tempz(k).MI,'LineWidth',1.5, 'Color',colors(ci,:))
            end
        end
    end
    tmpn = cell(1,length(parm));
    for n = 1:length(parm)
        if sk(n)== 0
            if mk(n) == 0
            tmpn{1,n}= ['HMM,G=' num2str(parm(n)) '-inh' ];
            elseif mk(n)== 1
            tmpn{1,n}= ['HMM,G=' num2str(parm(n)) '-exc' ];
            end
        elseif sk(n)==1
            tmpn{1,n}= ['OU,G=' num2str(parm(n)) ];
        end
    end
    legend(tmpn)
    xlim([-2000 2000])
    xlabel('time shift(ms)')
    ylabel('MI(in bits)')
    title(['cell' num2str(cell_id) ' type ' type{1,cell_id}])
    xline(0,'-','DisplayName','zero time shift');
    saveas(gcf,['type' type{1,cell_id} 'cell' num2str(cell_id) '.jpg'])
    hold off
    
    subplot(1,2,2)
    ci = 0;
    hold on
    %plot the reference voltage trace cell by cell
    for hmm_i = 1:size(hmm_r,2)
        tempz = hmm_r{1,hmm_i};
        for k = 1:length(tempz)%one g-value
            if tempz(k).ID == cell_id
                ci = ci+1;
                plot(tempz(k).voltage, 'Color',colors(ci,:))
            end
        end
    end
    hold off
    kk = files(cell_id).name;
    cd(fig_dir)
    saveas(gca,[kk(1:end-4) '.jpg'] )
end




