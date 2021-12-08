close all
clear all
clc
fn = 'offs_211111psth_cabnet.mat';%file name
pd = '/Users/Arthur/Documents/RiekeLab/celltype_3';%parent dr
cd(pd)
nd = fn(1:end-15);%extract the name tag
load(fn)%load each psth_cabnet

evos = [];
for i = 1:length(psth_cabnet)
    evos = [evos psth_cabnet(i).evo];
end

%find and trace the unique evos
evos_count = unique(evos);
evo_track = zeros(2,length(evos_count));
figure
hold on
for i = 1:length(evos_count)
    temp_a = length(find(evos==evos_count(i)));
    evo_track(1,i)= evos_count(i);%id number
    evo_track(2,i)= temp_a;%id number
    scatter(temp_a/length(psth_cabnet),evos_count(i))%scatter the percentage and use this to make decision
end
hold off
evos_to_consider = input('how many evos you want?')%input the number that we want;
evo_track_m = evo_track;%create a mirror to evo_track
evo_final = [];%the evo names we want to keep
evo_final_cnt = [];%the evo count under same names
for i = 1:evos_to_consider
    [m1,i1]= max(evo_track_m(2,:));
    evo_final = [evo_final evo_track_m(1,i1)];
    evo_final_cnt = [evo_final_cnt evo_track_m(2,i1)];
    evo_track_m(2,i1) = -99;
end

%patch name
name_patch = cell(1,1);
for i = 1:evos_to_consider
    name_patch{1,i} = num2str(evo_final(i));
end

mkdir(pd,nd)
cd(nd)
%plot average  and save each of each evos
for i = 1:evos_to_consider %each evolution
    tar = evo_final(i);
    temp_avg = zeros(size(psth_cabnet(1).imageStats.sampledPatches.images{1,1},1),size(psth_cabnet(1).imageStats.sampledPatches.images{1,1},2));%average image
    cnts = 0;
    for patch = 1:30%length(psth_cabnet)
        if psth_cabnet(patch).evo == tar
            cnts = cnts + 1;
%             figure
%             imagesc(psth_cabnet(patch).imageStats.sampledPatches.images{1,1})
%             colormap(gray)
%             saveas(gca,[num2str(tar) '_' num2str(cnts) '.jpg'])
            temp_avg = temp_avg + psth_cabnet(patch).imageStats.sampledPatches.images{1,1};
            
        end
        
    end
    %plotting and saving the average picture
    temp_avg = temp_avg/cnts;%devided by counts;
    sum_int = sum(sum(temp_avg));%sum the intensity
%     figure
%     imagesc(temp_avg)
%     colormap(gray)
%     saveas(gca,['avg_' num2str(tar) '_' num2str(sum_int) '.jpg'])
end

%
%plot the distrubtuion for the statics 

%pixel level histogram
figure
for i = 1:evos_to_consider %each evolution
    tar = evo_final(i);
    to_consider = linspace(0,0.2,1001);
    temp_h = zeros(1,length(to_consider)-1);
    cnt = 1;
    for patch = 1:length(psth_cabnet)
        if psth_cabnet(patch).evo == tar
            h = histcounts(reshape(psth_cabnet(patch).imageStats.sampledPatches.images{1,1},1,[]),to_consider);
            temp_h = temp_h+ h;
            cnt = cnt+1;
        end
    end
    subplot(evos_to_consider,1,i)
    plot( to_consider(2:end),(temp_h/cnt)/sum(temp_h/cnt))
    ylabel('relative fequency')
    title('Pixel value distrubution')
    legend(name_patch{1,i} )
end
saveas(gca,['pixel_hist' '.jpg'])
%

%mean of the patch 
figure
for i = 1:evos_to_consider %each evolution
    tar = evo_final(i);
    temp_h = [];
    for patch = 1:length(psth_cabnet)
        if psth_cabnet(patch).evo == tar
            temp_h = [temp_h,ip_average(psth_cabnet(patch).imageStats.sampledPatches.images{1,1},psth_cabnet(patch).imageStats.backgroundIntensity)];
        end
    end
    subplot(evos_to_consider,1,i)
    histogram(temp_h,-1:0.05:1)
    title('mean of patch')
    legend(name_patch{1,i} )
end
saveas(gca,['meanPatch' '.jpg'])


%image std
figure
for i = 1:evos_to_consider %each evolution
    tar = evo_final(i);
    temp_h = [];
    for patch = 1:length(psth_cabnet)
        if psth_cabnet(patch).evo == tar
            temp_h = [temp_h,ip_std(psth_cabnet(patch).imageStats.sampledPatches.images{1,1})];
        end
    end
   subplot(evos_to_consider,1,i)
histogram(temp_h,0:0.01:0.4)
 %histogram(temp_h)
    title('SD of patch')
    legend(name_patch{1,i} )
end

saveas(gca,['SDPatch' '.jpg'])

%contrast
figure
for i = 1:evos_to_consider %each evolution
    tar = evo_final(i);
    temp_h = [];
    for patch = 1:length(psth_cabnet)
        if psth_cabnet(patch).evo == tar
            temp_h = [temp_h,ip_contast(psth_cabnet(patch).imageStats.sampledPatches.images{1,1},psth_cabnet(patch).imageStats.backgroundIntensity)];
        end
    end
    subplot(evos_to_consider,1,i)
    histogram(temp_h,0:0.01:0.4)
    title('Contrast')
    legend(name_patch{1,i} )
end
saveas(gca,['contrast' '.jpg'])


cd(pd)
