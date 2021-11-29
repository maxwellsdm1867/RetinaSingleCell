%% get patch locations and statistics

 

node = gui.getSelectedEpochTreeNodes;
params.pixelSize = 0.97;%parameter for rigG
params.subunitRadius = 15/params.pixelSize;   % subunit radius in pixels (enter size in microns)          
params.subunitFlag = 1;
%params.rfSigmaCenter = node{1}.epochList.elements(1).protocolSettings.get('apertureDiameter')/params.pixelSize;
params.rfSigmaCenter = node{1}.epochList.elements(1).protocolSettings.get('apertureDiameter')/3/params.pixelSize;

imageStats = getImageStats(node, params);%this step extract the image and partial image
centerStats.imageStats = imageStats;
figure
colormap(gray)
imagesc(imageStats.sampledPatches.images{1,1})

%this should be add back to the psth_cabnet
contrast = imageStats.SDPatch ./ (imageStats.backgroundIntensity + imageStats.meanPatch)
center
