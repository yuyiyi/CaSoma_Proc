%% Load imaging data (must be in correct data directory
fn = '12-WFOV6_5Dwell3-sm.tif';

mov = kyoLoadStackTIFF(fn,0);
clear movR
mov=double(mov);

%% Make the cross corr image
if size(mov,3) > 4000
    [ccimage]=kyoCrossCorrImage(mov(:,:,1:4000));
else
    [ccimage]=kyoCrossCorrImage(mov);
end
%% Automatically make ROIs
minArea = 5; % for 512x512, z2-3, use 15; for 256x128, z3, use 5
%[rois]=kyoMakeROIsFromCCimage(ccimage,minArea,1);
[rois]=kyoMakeROIsFromCCimage(ccimage,minArea,1,[6 6 -0.05]);

% Check ROIs by hand
kyoBrowseROIsGUI(rois,mov)
%% ALTERNATE  FOR GIANT IMAGES
minArea = 5;
tic
[roisA]=kyoMakeROIsFromCCimage(ccimage(:,1:512),minArea,1,[6 6 -0.05]);
[roisB]=kyoMakeROIsFromCCimage(ccimage(:,513:end),minArea,1,[6 6 -0.05]);
toc
%%
rois=zeros([size(ccimage) (size(roisA,3) + size(roisB,3))]);
rois(:,1:512,1:size(roisA,3))=roisA;
rois(:,513:1024,size(roisA,3)+1:size(rois,3))=roisB;
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