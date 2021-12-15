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
list = loader.loadEpochList([exportFolder 'doves_2000.mat'], dataFolder);

dateSplit = @(list)splitOnExperimentDate(list);
dateSplit_java = riekesuite.util.SplitValueFunctionAdapter.buildMap(list, dateSplit);
cellTypeSplit = @(list)splitOnCellType(list);
cellTypeSplit_java = riekesuite.util.SplitValueFunctionAdapter.buildMap(list, cellTypeSplit);

tree = riekesuite.analysis.buildTree(list, {cellTypeSplit_java,dateSplit_java,'protocolID','cell.label','protocolSettings(imageName)','protocolSettings(background:FilterWheel:NDF)'});

gui = epochTreeGUI(tree);

%% plot the averge responce(psth) of each patch number on different levels
node = gui.getSelectedEpochTreeNodes;
thres = 4;%std threshold
spike_view = true;
sd = '/Users/Arthur/Documents/RiekeLab/DOVEs';
datz = '211026';
cell_type = 'onT_zz';
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
            fnt = 'test';%just the place holder
            spike_time = spike_detection(data(i,:),thres,fnt,spike_view);
            [BinningSpike] = BinSpk1(bin_interval,spike_time/10000,stim_dur);
            temp_psth = temp_psth+BinningSpike;
        end
        psth = temp_psth/size(data,1);%averge psth for each light level
        plot(psth)
        avg_psth(lightLevel,:)= psth; %get the average response for scatter
        %and normalization
    end
    
    legend('100','10','1')
    hold off
    cd(sd)
    lvs = size(avg_psth,1);
    close
    %plot normailzed psth
    figure
    hold on
    for i = 1:lvs
        t_psth = avg_psth(i,:)/sum(avg_psth(i,:));%normalize
        plot(t_psth)
    end
    legend('100','10','1')
    hold off
    xlabel(sd)
    saveas(gcf,['doves_' cell_type '_' datz '_' num2str(num_pat) '.jpg'])%and this is the off transient on tuesday
    close
    
    
    %scatter plot for the phase diagram, convolve with gaussian filter
    half_width = 150;
    fact = 25;
    y = normpdf(-half_width:half_width,0);%[he gaussian filter
    smooth_psth = zeros(size(avg_psth,1),fact*size(avg_psth,2));
    for j = 1:lvs
        temp = avg_psth(j,:);
        h = interp(conv(temp,y,'same'),fact);
        smooth_psth(j,:) = h;
    end
    figure('units','normalized','outerposition',[0 0 1 1])
    scatter(smooth_psth(1,:),smooth_psth(2,:))
    xlabel('100 r*')
    ylabel('10r*')
    saveas(gcf,['doves_' cell_type '_' datz '_' num2str(num_pat) '_r100.jpg'])
    if lvs== 3
    figure
    scatter(smooth_psth(2,:),smooth_psth(3,:))
    xlabel('10 r*')
    ylabel('1 r*')
    saveas(gcf,['doves_' cell_type '_' datz '_' num2str(num_pat) '_r10.jpg'])
    end
end

close all
%scatter(avg_psth(t,:),avg_psth(t-1,:))
% scatter(smooth_psth(t,:),smooth_psth(t-1,:))
% figure
% hold on
% plot(smooth_psth(t,:))
% plot(smooth_psth(t-1,:))
% hold off