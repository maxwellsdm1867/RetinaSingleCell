function imageStats = getImageStats(node, params)

    rfSigmaCenter = params.rfSigmaCenter/params.pixelSize;
    backgroundIntensity = node{1}.epochList.elements(1).protocolSettings.get('backgroundIntensity');
    imageStats.backgroundIntensity = backgroundIntensity;
    for CurNode = 1:length(node)
        %keyboard
        tempLoc = node{CurNode}.children(1).epochList.elements(1).protocolSettings.get('currentPatchLocation');
%        tempLoc = node{CurNode}.epochList.elements(1).protocolSettings.get('currentPatchLocation');
        tempLocArray = tempLoc.toArray;
        patchLocations(CurNode, :) = tempLocArray(:);
    end

    imageName = node{1}.children(1).epochList.elements(1).protocolSettings.get('imageName');
%    imageName = node{1}.epochList.elements(1).protocolSettings.get('imageName');
%keyboard
    sampledPatches = getNaturalImagePatchFromLocation(patchLocations, imageName, 'imageSize', [rfSigmaCenter*2 rfSigmaCenter*2]);

    % subunit filters
    for x = 1:size(sampledPatches.images{1}, 1)
        for y = 1:size(sampledPatches.images{1}, 1)
            SubunitFilter(x,y) = exp(-((x - size(sampledPatches.images{1}, 1)/2).^2 + (y - size(sampledPatches.images{1}, 1)/2).^2) / (2 * (params.subunitRadius^2)));
            DistanceFromCenter = sqrt((x - size(sampledPatches.images{1}, 1)/2)^2 + (y - size(sampledPatches.images{1}, 1)/2)^2);
            if (DistanceFromCenter < (rfSigmaCenter*1))
                statsIndices(x,y) = 1;
            else
                statsIndices(x,y) = 0;
            end
        end
    end
    SubunitFilter(:) = SubunitFilter(:) / sum(SubunitFilter(:));
    
    Indices = find(statsIndices(:) == 1);

    % stats after convolution with subunit filter
    for CurNode = 1:length(node)
        ImagePatch = sampledPatches.images{CurNode};
        ImagePatch(:) = (ImagePatch(:) - backgroundIntensity)/backgroundIntensity;
        if (params.subunitFlag)%this is the subunit filter
            ImagePatch = conv2(ImagePatch, SubunitFilter, 'same');    
        end
        imageStats.meanPatch(CurNode) = mean(ImagePatch(Indices));
        imageStats.SDPatch(CurNode) = std(ImagePatch(Indices));
        ImagePatch(:) = ImagePatch(:) - mean(ImagePatch(:));
        NegIndices = find(ImagePatch(Indices) < 0);
        PosIndices = find(ImagePatch(Indices) > 0);
        imageStats.PosNegRatio(CurNode) = length(NegIndices) / (length(PosIndices) + length(NegIndices));
    end
    imageStats.SDPatch = imageStats.SDPatch;
    imageStats.sampledPatches = sampledPatches;
    
return