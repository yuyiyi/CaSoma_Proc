%% Load imaging data (must be in correct data directory
fn = 'RL-opticflow002.tif';

[movR,mov] = kyoLoadStackTIFF(fn,1);
clear movR
mov=double(mov);

% Stimulus info
sfv=0; % remember to paste the stim frame vector from Igor into this variable

%stimNames = {'ori0' 'ori45' 'ori90' 'ori135' 'ori180' 'ori225' 'ori270' 'ori315'};
%stimNames = {'patch50'};
stimNames = {'up' 'left' 'down' 'right' 'zoomIn' 'zoomOut' 'rotCCW' 'rotCW'};
numReps = 5;

%% Make Scenes
Scenes = kyoConvertSFVtoScenes(sfv,stimNames,numReps);

% Make the cross corr image
if size(mov,3) > 4000
    [ccimage]=kyoCrossCorrImage(mov(:,:,1:4000));
else
    [ccimage]=kyoCrossCorrImage(mov);
end

%% Automatically make ROIs
minArea = 5; % for 512x512, z2-3, use 15; for 256x128, z3, use 5
[rois]=kyoMakeROIsFromCCimage(ccimage,minArea,1);

% Check ROIs by hand
kyoBrowseROIsGUI(rois,mov)
%% Rename the keeps
ROIkeeps=ROI_keepToggles;
%% Step 1 of 2: Split ROIs that need it (repeat as needed)
r=67;
kyoROIGUI(ccimage.*256,rois(:,:,r))
%% Step 2 of 2: Add the new ROIs (repeat these two steps for all ROIs that need to be split)
a=size(rois,3);
b=size(ROIsFromGUI,3)-1;
rois(:,:,a+1:a+b) = ROIsFromGUI(:,:,2:b+1);
ROIkeeps(a+1:a+b)=1;
ROIkeeps(r)=0;
%% Delete ROIs that we don't want to keep
rois=rois(:,:,ROIkeeps>0);
% Get time courses
tc=kyoGetTCs(mov,rois);
imagesc(tc')
% Clean up
clear r a b ROIkeeps ROI_keepToggles ROIsFromGUI minArea