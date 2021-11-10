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
node = gui.getSelectedEpochTreeNodes;%import the checked data
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
%% PCA and kmeas clustering
%coeff = pca(X) returns the principal component coefficients, also known as loadings,
%for the n-by-p data matrix X. Rows of X correspond to observations and columns correspond to variables.
%The coefficient matrix is p-by-p. Each column of coeff contains coefficients for one principal component,
%and the columns are in descending order of component variance.
cd('/Users/Arthur/Documents/RiekeLab/211104') %directory of saved fiugres
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
save('psth_cabnet','psth_cabnet')



