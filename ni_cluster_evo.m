%ni_cluster evolution
%see how response to one image patch cha
close all
clear all
clc
%load('/Users/Arthur/Documents/RiekeLab/210923/210923cabnet.mat')%on_s
%load('/Users/Arthur/Documents/RiekeLab/211005/211005cabnet.mat')%off_s
load('/Users/Arthur/Documents/RiekeLab/211026/211026cabnet.mat')%on_t
for i = 1:30
    clus_id(i,1) = psth_cabnet(i).r100c;
    clus_id(i,2) = psth_cabnet(i).r010c;
    clus_id(i,3) = psth_cabnet(i).r001c;
end
close all
figure
lut1 = histogram2(clus_id(:,2),clus_id(:,1));
xlabel('10r* cluster id')
ylabel('100r* cluster id')
figure
lut2 = histogram2(clus_id(:,3),clus_id(:,2));
xlabel('1r* cluster id')
ylabel('10r* cluster id')
lut1.Values
lut2.Values
tar =2;
figure
hold on
for i = 1:30
    if psth_cabnet(i).r100c == tar 
        plot(psth_cabnet(i).r100)
    end
end
hold off