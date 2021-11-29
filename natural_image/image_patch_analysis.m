close all
clear all
clc

load('onS_210923psth_cabnet.mat')%load each psth_cabnet

evos = [];
for i = 1:length(psth_cabnet)
    evos = [evos psth_cabnet(i).evo];
end

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


%plot the average of each evos
for i = 1:evos_to_consider
    tar = evo_final(i);
    for patch = 1:length(psth_cabnet)
        if psth_cabnet(patch).evo == tar
            
            saveas(gca,['ev_' tpyz '_' datz '_' num2str(tar) '.jpg'])
        end
    end
    
end



