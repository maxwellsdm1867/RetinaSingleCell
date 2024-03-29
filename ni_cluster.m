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

cellTypeSplit = @(list)splitOnCellType(list);
cellTypeSplit_java = riekesuite.util.SplitValueFunctionAdapter.buildMap(list, cellTypeSplit);
tree = riekesuite.analysis.buildTree(list, {cellTypeSplit_java, dateSplit_java,'protocolID','cell.label','protocolSettings(imageName)','protocolSettings(imagePatchIndex)','protocolSettings(background:FilterWheel:NDF)'});
%tree = riekesuite.analysis.buildTree(list, {dateSplit_java,'protocolID','cell.label','protocolSettings(imagePatchIndex)','protocolSettings(background:FilterWheel:NDF)'});

cd('/Users/Arthur/Documents/RiekeLab/celltype_3') %directory of saved fiugres


gui = epochTreeGUI(tree);%open gui
%% extract the data to a cell, by each image patch and
%this requires a rewrite where we need to label it and save the cluster id


datz = '211014';
tpyz = 'offT';

spike_view = true;
thres = 3.2;
%node = gui.getSelectedEpochTreeNodes;%chosees a cell ID


%image pathch extraction
s_node = cell(1,1);%node for extracting the image patches, should add conversion later so
params.pixelSize = 0.97;%parameter for rigG
params.subunitRadius = 15/params.pixelSize;   % subunit radius in pixels (enter size in microns)
params.subunitFlag = 1;
params.rfSigmaCenter = node{1}.epochList.elements(1).protocolSettings.get('apertureDiameter')/3/params.pixelSize;

%this data is grouped by cell->image ID->patch ID->light levels->epoches
cnt_psth = 1; %index for the struct
for image_id = 1%:node{1}.children.length %number of image
    for patch_id = 1:node{1}.children(1).children.length %identifer of the image in each patch
        
        
        %extract the image patch and save to psth_cabnet
        s_node(1,1) = node{1}.children(1).children(patch_id);
        imageStats = getImageStats(s_node, params);%this step extract the image and partial image
        centerStats.imageStats = imageStats;

        for light_levels = 1:node{1}.children(1).children(1).children.length
            %extract indivisual epochs
            data = riekesuite.getResponseMatrix(node{1}.children(image_id).children(patch_id).children(light_levels).epochList, params.Amp);
            %compute psth
            temp_psth = zeros(1,100);%reset psth for each light level
            psth_cabnet(cnt_psth).imageStats = imageStats;%save the image stats
            for i = 1:size(data,1)
         
                %spike_time = spike_detection(data(i,:))/10000;%soike detection
                fnt = ['sdch_im_' num2str(image_id) '_patch_' num2str(patch_id) '_lv_' num2str(light_levels) '_rpt_' num2str(i)];
               % [spike_time, SpikeAmplitudes, RefractoryViolations] = Detector1(data(i,:));%,'CheckDetection',true);
                %[spike_time, SpikeAmplitudes, RefractoryViolations] = Detector1(data(i,:),fnt,'CheckDetection',true);
                spike_time = spike_detection(data(i,:),thres,fnt,spike_view);
                [BinningSpike] = BinSpk1(0.010,spike_time/10000,1);% bin the spike to get firing rate
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
%

% PCA and kmeas clustering
%coeff = pca(X) returns the principal component coefficients, also known as loadings,
%for the n-by-p data matrix X. Rows of X correspond to observations and columns correspond to variables.
%The coefficient matrix is p-by-p. Each column of coeff contains coefficients for one principal component,
%and the columns are in descending order of component variance.

tot_patch = cnt_psth-1;%number of patches
%extract the hightest leight levels
light_level_id = ['r100';'r010';'r001'];
for exc = 1:3
    for i = 1:tot_patch
        eval(['pre_clust(i,:) = psth_cabnet(i).' light_level_id(exc,:) ])%data matrix for clustering using the highest light level
    end
    
    coef_psth = pca(pre_clust);% every column of coeff psth is coeff for one component
    %project to pc1 and pc2
    p1 = coef_psth(:,1);%pc1
    p2 = coef_psth(:,2);%pc2
    p1_r = pre_clust*p1;
    p2_r = pre_clust*p2;
    ok = 0;
    while ok ~= 1
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
            saveas(gca,[ 'NIF_' tpyz '_' light_level_id(exc,:) 'cluster' num2str(i) '_' datz '.jpg'])
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
        ok = input('ok?');
        close
    end
    
    
    
    saveas(gca,['NIF_' tpyz '_' datz '_' light_level_id(exc,:) 'cluster_scatter' num2str(i)  '.jpg'])
    %% overwriting scsatter plot and find their relations
    for i = 1:length(classes)
        eval(['psth_cabnet(i).' light_level_id(exc,:) 'c = classes(i)']);
    end
end

%dealing with each evolution id
evos = [];
for i = 1:length(classes)
    psth_cabnet(i).evo = psth_cabnet(i).r100c+psth_cabnet(i).r010c*10+psth_cabnet(i).r001c*100;%low mid high
    evos = [evos psth_cabnet(i).r100c+psth_cabnet(i).r010c*10+psth_cabnet(i).r001c*100];
end

save([tpyz '_' datz 'psth_cabnet'] , 'psth_cabnet')

%correspondence
for i = 1:length(psth_cabnet)
    clus_id(i,1) = psth_cabnet(i).r100c;
    clus_id(i,2) = psth_cabnet(i).r010c;
    clus_id(i,3) = psth_cabnet(i).r001c;
end

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


evos_count = unique(evos);
evo_track = zeros(2,length(evos_count));
figure
hold on
for i = 1:length(evos_count)
    temp_a = length(find(evos==evos_count(i)));
    evo_track(1,i)= evos_count(i);%id number
    evo_track(2,i)= temp_a;%id number
    scatter(temp_a/length(classes),evos_count(i))%scatter the percentage and use this to make decision
end
hold off
evos_to_consider = input('how many evos you want?')%input the number that we want;
%this is getting the first to nth largest population
evo_track_m = evo_track;%create a mirror to evo_track
evo_final = [];%the evo names we want to keep
evo_final_cnt = [];%the evo count under same names
for i = 1:evos_to_consider
    [m1,i1]= max(evo_track_m(2,:));
    evo_final = [evo_final evo_track_m(1,i1)];
    evo_final_cnt = [evo_final_cnt evo_track_m(2,i1)];
    evo_track_m(2,i1) = -99;
end
class1_h = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));
class1_m = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));
class1_l = zeros(size(psth_cabnet(1).r100,1),size(psth_cabnet(1).r100,2));
%plot the average of each evos
for i = 1:evos_to_consider
    tar = evo_final(i);
    tar_cnt = evo_final_cnt(i);
    for patch = 1:length(psth_cabnet)
        if psth_cabnet(patch).evo == tar
            class1_h = class1_h + psth_cabnet(patch).r100;
            class1_m = class1_m + psth_cabnet(patch).r010;
            class1_l = class1_l + psth_cabnet(patch).r001;
        end
        
    end
    class1_h = class1_h/tar_cnt;
    class1_m = class1_m/tar_cnt;
    class1_l = class1_l/tar_cnt;
    figure
    hold on
    plot(class1_h)
    plot(class1_m)
    plot(class1_l)
    hold off
    legend('100r*','10r*','1r*')
    title(['percentage ' num2str(tar_cnt/tot_patch) ' evolution of ' num2str(tar)])
    saveas(gca,['ev_' tpyz '_' datz '_' num2str(tar) '.jpg'])
end

clear psth_cabnet