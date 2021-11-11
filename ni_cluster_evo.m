%ni_cluster evolution
%see how response to one image patch
%struct is not the best way to store stuffs
close all
clear all
clc
%load('/Users/Arthur/Documents/RiekeLab/210923/210923cabnet.mat')%on_s
%load('/Users/Arthur/Documents/RiekeLab/211005/211005cabnet.mat')%off_s
load('/Users/Arthur/Documents/RiekeLab/211104/psth_cabnet.mat')%on_s
for i = 1:length(psth_cabnet)
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
ten_to_100 = lut1.Values
one_to_10 = lut2.Values
tar =2;
%they ususally haVe good correspondence wrt Each other
figure
hold on
for i = 1:length(psth_cabnet)
    if psth_cabnet(i).r100c == tar
        plot(psth_cabnet(i).r100)
    end
end
hold off

%plot the averge of each cluster for each light levels

for cluster_id = unique(clus_id)
    temp = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));
    for patch_id = 1:length(psth_cabnet)
        
    end
end


