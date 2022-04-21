%% Load imaging data (must be in correct data directory
fn = '19b-DualROI-again.tif';

[mov1,mov2] = kyoLoadStackTIFF(fn,1);

mov1=double(mov1);
mov2=double(mov2);

%% Make the cross corr image
if size(mov1,3) > 4000
    [ccimage1]=kyoCrossCorrImage(mov1(:,:,1:4000));
    [ccimage2]=kyoCrossCorrImage(mov2(:,:,1:4000));
else
    [ccimage1]=kyoCrossCorrImage(mov1);
    [ccimage2]=kyoCrossCorrImage(mov2);
end
%% Automatically make ROIs
minArea = 5; % for 512x512, z2-3, use 15; for 256x128, z3, use 5
%[rois]=kyoMakeROIsFromCCimage(ccimage,minArea,1);
[rois1]=kyoMakeROIsFromCCimage(ccimage1,minArea,1,[20 20 -0.1]);
[rois2]=kyoMakeROIsFromCCimage(ccimage2,minArea,1,[20 20 -0.1]);

%% Check ROIs by hand
kyoBrowseROIsGUI(rois2,mov2)
%% Rename the keeps
ROIkeeps=ROI_keepToggles;
%%
thresh=7;
[roisTh1,tc1]=kyoScreenKurt(rois1,mov1,thresh);
%
thresh=7;
[roisTh2,tc2]=kyoScreenKurt(rois2,mov2,thresh);
%% Delete ROIs that we don't want to keep
rois=rois(:,:,ROIkeeps>0);
% Get time courses
tc=kyoGetTCs(mov,rois);
imagesc(tc')
% Clean up
clear r a b ROIkeeps ROI_keepToggles ROIsFromGUI minArea
%% display time courses

tc=kyoGetTCs(mov2,roisTh2);
%%
tc=tc2;
figure
numRois = size(tc,2);
offset = 1;
for r=1:numRois
    plot(tc(:,r)+(offset*r));hold on
    axis off
end

roisOut = roisGood;
tcOut = tc;
%% display single frames

