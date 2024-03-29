%%
%*************************************************************************
% Initializations
%*************************************************************************


% define plot color sequence, axis fonts
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

%% making the parameter struct
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

%%
%*************************************************************************
%*************************************************************************
list = loader.loadEpochList([exportFolder 'test.mat'], dataFolder);

dateSplit = @(list)splitOnExperimentDate(list);
dateSplit_java = riekesuite.util.SplitValueFunctionAdapter.buildMap(list, dateSplit);

tree = riekesuite.analysis.buildTree(list, {dateSplit_java,'protocolID','cell.label','protocolSettings(imageName)','protocolSettings(imagePatchIndex)','protocolSettings(background:FilterWheel:NDF)'});

gui = epochTreeGUI(tree);

%%
node = gui.getSelectedEpochTreeNodes;%import the checked data


%%
% data = riekesuite.getResponseMatrix(node{1}.epochList, params.Amp);
% 
% %%
% for child = 1:node{1}.children.length
%     data = riekesuite.getResponseMatrix(node{1}.children(child).epochList, params.Amp);
%     figure(3); clf
%     plot(data(1, :));
%     pause(2);
% end

%% plot the averge responce(psth) of each patch number on different levels
%the data sceletion is based on image patch, not cell ID
clc
for num_pat = 1:node{1}.children.length %number of image patch
    figure
    hold on
    for lightLevel = 1:node{1}.children(1).children.length% DIFFERENT LIGHT LEVEL
        data = riekesuite.getResponseMatrix(node{1}.children(num_pat).children(lightLevel).epochList, params.Amp);%GET RAW DATA
        %spike detection and binning here
        temp_psth = zeros(1,100);
        for i = 1:size(data,1)
            spike_time = spike_detection(data(i,:))/10000;
            [BinningSpike] = BinSpk1(0.010,spike_time,1);
            temp_psth = temp_psth+BinningSpike;
        end
        size(data,1)
        psth = temp_psth/size(data,1);
        plot(psth)
    end
    
    legend('100','10','1')
    hold off
    cd('/Users/Arthur/Documents/RiekeLab/211104')
    saveas(gcf,['NIF_im1patch' num2str(num_pat) '.jpg'])
    close
end




