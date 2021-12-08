%%
%*************************************************************************
% Initializations
%*************************************************************************
close all
clear all
clc

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

%
%*************************************************************************
%*************************************************************************
list = loader.loadEpochList([exportFolder 'doves_s_size.mat'], dataFolder);

dateSplit = @(list)splitOnExperimentDate(list);
dateSplit_java = riekesuite.util.SplitValueFunctionAdapter.buildMap(list, dateSplit);
cellTypeSplit = @(list)splitOnCellType(list);
cellTypeSplit_java = riekesuite.util.SplitValueFunctionAdapter.buildMap(list, cellTypeSplit);

tree = riekesuite.analysis.buildTree(list, {cellTypeSplit_java,dateSplit_java,'protocolID','cell.label','protocolSettings(imageName)','protocolSettings(background:FilterWheel:NDF)'});

gui = epochTreeGUI(tree);

%%
%choose one cell to be one node
node = gui.getSelectedEpochTreeNodes;%import the checked data


%
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
thres = 4;%std threshold 
spike_view = true;
sd = '/Users/Arthur/Documents/RiekeLab/DOVEs';
datz = '211019';
cell_type = 'offS';
clc
for num_pat = 1:node{1}.children.length %number of movie clip
    figure
    hold on
    avg_psth = zeros(node{1}.children(1).children.length,675);
    for lightLevel = 1:node{1}.children(1).children.length% DIFFERENT LIGHT LEVEL
        data = riekesuite.getResponseMatrix(node{1}.children(num_pat).children(lightLevel).epochList, params.Amp);%GET RAW DATA
        %spike detection and binning here
        stim_dur = size(data,2)/10000;%stimulus length in time(sec)
        bin_interval = 0.010;
        temp_psth = zeros(1,stim_dur/bin_interval);
        for i = 1:size(data,1)
           fnt = 'test'
            spike_time = spike_detection(data(i,:),thres,fnt,spike_view);
            [BinningSpike] = BinSpk1(bin_interval,spike_time/10000,stim_dur);
            temp_psth = temp_psth+BinningSpike;
        end
        size(data,1)
        psth = temp_psth/size(data,1);%averge psth for each light level
        plot(psth)
        avg_psth(lightLevel,:)= psth; %get the average response for scatter
        %and normalization
    end
    
    legend('100','10','1')
    hold off
    cd(sd)
    saveas(gcf,['120dove' num2str(num_pat) '.jpg'])
    lvs = size(avg_psth,1);
    close
    %plot normailzed psth
    figure
    hold on
    for i = 1:lvs
        t_psth = avg_psth(i,:)/max(avg_psth(i,:));
        plot(t_psth)
    end
    legend('100','10','1')
    hold off
    xlabel(sd)
    saveas(gcf,['doves_' cell_type '_' datz '_' num2str(num_pat) '.jpg'])%and this is the off transient on tuesday
    close
    
    
    %scatter plot for the phase diagram
%     figure
%     for i = size(avg_psth,1):2
%         scatter(avg_psth(i,:),avg_psth(i-1,:))
%         xlabel('resp @ 10 r*')
%         ylabel('resp @ 100 r*')
%         saveas(gcf,['2000doveScatter' num2str(num_pat) '.jpg'])
%     end
%     close
end




