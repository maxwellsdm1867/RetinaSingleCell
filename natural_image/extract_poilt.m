%extract test
%extract from each image patch and plot them
%the task here is to select a cell and put this into psth_cabnet so it will
%be esaier to extract


node = gui.getSelectedEpochTreeNodes;%select patch munber(1-30)
%the trick might be switching the definitetion of the node

%parameter setting
params.pixelSize = 0.97;%parameter for rigG
params.subunitRadius = 15/params.pixelSize;   % subunit radius in pixels (enter size in microns)
params.subunitFlag = 1;
params.rfSigmaCenter = node{1}.epochList.elements(1).protocolSettings.get('apertureDiameter')/3/params.pixelSize;


%extraction
imageStats = getImageStats(node, params);%this step extract the image and partial image
centerStats.imageStats = imageStats;

%visualization

figure
imagesc(imageStats.sampledPatches.images{1,1})
colormap(gray)



node = gui.getSelectedEpochTreeNodes;%chosees a cell ID
s_node = cell(1,1);
%
%this data is grouped by cell->image ID->patch ID->light levels->epoches
cnt_psth = 1; %index for the struct
for image_id = 1:node{1}.children.length %number of image
    for patch_id = 1:node{1}.children(1).children.length %identifer of the image in each patch
        s_node(1,1) = node{1}.children(1).children(patch_id);
        imageStats = getImageStats(s_node, params);%this step extract the image and partial image
        centerStats.imageStats = imageStats;
        
        figure
        imagesc(imageStats.sampledPatches.images{1,1})
        colormap(gray)
        pause(1)
        close
        
    end
end
