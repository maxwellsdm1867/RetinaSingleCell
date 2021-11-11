%clustering by indivisaul impage patch
%create a stuct of meta data plus the average of the response to that patch
%under different level
close all
clear all
clc

PlotColors = 'bgrkymcbgrkymcbgrkymcbgrkymc';
set(0, 'DefaultAxesFontName','Helvetica')
set(0, 'DefaultAxesFontSize', 16)

colormap([0 0 0])
scrsz = get(0, 'ScreenSize');

% jauimodel stuff
loader = edu.washington.rieke.Analysis.getEntityLoader();
treeFactory = edu.washington.rieke.Analysis.getEpochTreeFactory();

%Data and export folder paths
dataFolder = '/Users/arthur/Data/';%SQL files
exportFolder = '/Users/arthur/Data/';%export from Ovation

import auimodel.*
import vuidocument.*

% making the parameter struct
params.FrequencyCutoff = 500;
params.Amp = 'Amp1';
params.Verbose = 1;
params.DecimatePts = 200;
params.SamplingInterval = 0.0001;
params.FrameRate = 60.1830;
params.OvationFlag = 1;
params.SpatialFlag = 0;
params.SaveToIgor = 0;
params.saveGraphs = 1;
params.rootDir = '~/LargeCells/';
list = loader.loadEpochList([exportFolder 'test.mat'], dataFolder);

dateSplit = @(list)splitOnExperimentDate(list);
dateSplit_java = riekesuite.util.SplitValueFunctionAdapter.buildMap(list, dateSplit);

tree = riekesuite.analysis.buildTree(list, {dateSplit_java,'protocolID','cell.label','protocolSettings(imageName)','protocolSettings(imagePatchIndex)','protocolSettings(background:FilterWheel:NDF)'});


gui = epochTreeGUI(tree);%open gui
%% extract the data to a cell, by each image patch and
%this requires a rewrite where we need to label it and save the cluster id

node = gui.getSelectedEpochTreeNodes;%chosees a cell ID
%
%this data is grouped by cell->image ID->patch ID->light levels->epoches
cnt_psth = 1; %index for the struct
for image_id = 1:node{1}.children.length %number of image
    for patch_id = 1:node{1}.children(1).children.length %identifer of the image in each patch
        for light_levels = 1:node{1}.children(1).children(1).children.length
            %extract indivisual epochs
            data = riekesuite.getResponseMatrix(node{1}.children(image_id).children(patch_id).children(light_levels).epochList, params.Amp);
            %compute psth
            temp_psth = zeros(1,100);%reset psth for each light level
            for i = 1:size(data,1)
                spike_time = spike_detection(data(i,:))/10000;%soike detection
                [BinningSpike] = BinSpk1(0.010,spike_time,1);% bin the spike to get firing rate
                temp_psth = temp_psth+BinningSpike;% addtion for later averge
            end
            psth = temp_psth/size(data,1);%average spikes
            %spilt the psth in thir corresponing light levels
            if light_levels == 1% light level is 100r*/sec
                psth_cabnet(cnt_psth).r100 = psth;
            elseif light_levels == 2% light level is 10r*/sec
                psth_cabnet(cnt_psth).r010 = psth;
            elseif light_levels == 3% light level is 1r*/sec
                psth_cabnet(cnt_psth).r001 = psth;
            else
                disp('check conditions!!!')%catch the errors
                keyboard
            end
            
        end
        cnt_psth = cnt_psth+1;% only need to advance the count when
    end
end


% PCA and kmeas clustering
%coeff = pca(X) returns the principal component coefficients, also known as loadings,
%for the n-by-p data matrix X. Rows of X correspond to observations and columns correspond to variables.
%The coefficient matrix is p-by-p. Each column of coeff contains coefficients for one principal component,
%and the columns are in descending order of component variance.
cd('/Users/Arthur/Documents/RiekeLab/211014') %directory of saved fiugres
tot_patch = cnt_psth-1;%number of patches
%extract the hightest leight levels
light_level_id = ['r100';'r010';'r001'];
for exc = 1:3
    for i = 1:tot_patch
        eval(['pre_clust(i,:) = psth_cabnet(i).' light_level_id(exc,:) ])%data matrix for clustering using the highest light level
    end
    
    coef_psth = pca(pre_clust);% every column of coeff psth is coeff for one component
    close all
    %project to pc1 and pc2
    p1 = coef_psth(:,1);%pc1
    p2 = coef_psth(:,2);%pc2
    p1_r = pre_clust*p1;
    p2_r = pre_clust*p2;
    % figure
    % scatter(p1_r,p2_r)
    % xlabel('PC1')
    % ylabel('PC2')
    
    %kmeans clustering in high dim and assign them to clusters, here we use the
    %elbow method
    klist=2:10;%the number of clusters you want to try
    myfunc = @(X,K)(kmeans(X, K));
    eva = evalclusters(pre_clust,myfunc,'CalinskiHarabasz','klist',klist);
    classes=kmeans(pre_clust,eva.OptimalK);%the id of each elements
    c_val = unique(classes);%number of clusters
    for i = 1:length(c_val)
        figure
        hold on
        for pat_id = 1:tot_patch
            if classes(pat_id) == i
                eval(['plot(psth_cabnet(pat_id).' light_level_id(exc,:) ')'])%change this line
            end
        end
        hold off
        title(['cluster' num2str(i)])
        saveas(gca,['NIF_' light_level_id(exc,:) 'cluster' num2str(i) '.jpg'])
    end
    figure%scatter plot that indicate different clusters
    hold on
    for i = 1:length(c_val)
        tp1 = p1_r(classes==i);
        tp2 = p2_r(classes==i);
        scatter(tp1,tp2)
    end
    legend('cluster 1','cluster 2')
    hold off
    xlabel('pc1')
    ylabel('pc2')
    saveas(gca,['NIF_' light_level_id(exc,:) 'cluster_scatter' num2str(i) '.jpg'])
    %% overwriting scsatter plot and find their relations
    for i = 1:length(classes)
        eval(['psth_cabnet(i).' light_level_id(exc,:) 'c = classes(i)']);
    end
end
for i = 1:length(classes)
    psth_cabnet(i).evo = psth_cabnet(i).r100c+psth_cabnet(i).r010c*10+psth_cabnet(i).r001c*100;%low mid high
end
%start from here 
save('psth_cabnet','psth_cabnet')
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
[m1, i1] = max(one_to_10);
[m2, i2] = max(ten_to_100);
ids = [1:2;i1;i2];
tag1 = num2str(100*ids(1,1)+10*ids(2,1)+ids(3,1));
tag2 = 121;%num2str(100*ids(1,2)+10*ids(2,2)+ids(3,2));
class1_h = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));
class2_h = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));
class1_m = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));
class2_m = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));
class1_l = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));
class2_l = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));

c1_c = 0;
c2_c = 0;
for patch = 1:length(psth_cabnet)
    if psth_cabnet(patch).evo == tag1
        class1_h = class1_h + psth_cabnet(patch).r100;
        class1_m = class1_m + psth_cabnet(patch).r010;
        class1_l = class1_l + psth_cabnet(patch).r001;
        c1_c = c1_c+1;
    elseif psth_cabnet(patch).evo == tag2
        class2_h = class2_h + psth_cabnet(patch).r100;
        class2_m = class2_m + psth_cabnet(patch).r010;
        class2_l = class2_l + psth_cabnet(patch).r001;
        c2_c = c2_c+1;
    end
    
end
class1_h = class1_h/c1_c;
class1_m = class1_m/c1_c;
class1_l = class1_l/c1_c;

class2_h = class2_h/c2_c;
class2_m = class2_m/c2_c;
class2_l = class2_l/c2_c;

for i = 1:2
    figure
    hold on
    eval(['plot(class' num2str(i) '_h)'])
    eval(['plot(class' num2str(i) '_m)'])
    eval(['plot(class' num2str(i) '_l)'])
    title(['class' num2str(i)])
    hold off
    legend('100r*','10r*','1r*')
    saveas(gcf,['group' num2str(i) '.jpg'])
end
% %%
% tagz = 3;
% tag1 = '211';
% tag2 = '122';
% tag3 = '123';
% for i = 1:tagz
%     eval(['class' num2str(i) '_h = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));'])
%     eval(['class' num2str(i) '_m = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));'])
%     eval(['class' num2str(i) '_l = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));'])
% end
% 
% c1_c = 0;
% c2_c = 0;
% c3_c = 0;
% for i = 1:tagz
%     
%     for patch = 1:length(psth_cabnet)
%         if psth_cabnet(patch).evo == tag1
%             class1_h = class1_h + psth_cabnet(patch).r100;
%             class1_m = class1_m + psth_cabnet(patch).r010;
%             class1_l = class1_l + psth_cabnet(patch).r001;
%             c1_c = c1_c+1;
%         elseif psth_cabnet(patch).evo == tag2
%             class2_h = class2_h + psth_cabnet(patch).r100;
%             class2_m = class2_m + psth_cabnet(patch).r010;
%             class2_l = class2_l + psth_cabnet(patch).r001;
%             c2_c = c2_c+1;
%         elseif psth_cabnet(patch).evo == tag3
%             class3_h = class3_h + psth_cabnet(patch).r100;
%             class3_m = class3_m + psth_cabnet(patch).r010;
%             class3_l = class3_l + psth_cabnet(patch).r001;
%             c3_c = c3_c+1;
%         end
%         
%     end
% end
% for i = 1:tagz
%     eval(['class' num2str(i) '_h = class' num2str(i) '_h/c' num2str(i) '_c;'])
%     eval(['class' num2str(i) '_m = class' num2str(i) '_m/c' num2str(i) '_c;'])
%     eval(['class' num2str(i) '_l = class' num2str(i) '_l/c' num2str(i) '_c;'])
%     
% end
% for i = 1:tagz
%     figure
%     hold on
%     eval(['plot(class' num2str(i) '_h)'])
%     eval(['plot(class' num2str(i) '_m)'])
%     eval(['plot(class' num2str(i) '_l)'])
%     eval(['title(['class' tag])])
%     hold off
%     legend('100r*','10r*','1r*')
%     saveas(gcf,['group' num2str(i) '.jpg'])
%     
% end