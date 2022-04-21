%% Make the cross corr image
[ccimage]=kyoCrossCorrImage(mov);
%% Automatically make ROIs
minArea = 15;
displayResults = 1;
[rois]=kyoMakeROIsFromCCimage(ccimage,minArea,displayResults);
%% Check ROIs by hand
kyoBrowseROIsGUI(rois,mov)
%% Rename the keeps
ROIkeeps=ROI_keepToggles;
%% Step 1 of 2: Split ROIs that need it (repeat as needed)
r=12;
kyoROIGUI(ccimage.*256,rois(:,:,r))
%% Step 2 of 2: Add the new ROIs (repeat these two steps for all ROIs that need to be split)
a=size(rois,3);
b=size(ROIsFromGUI,3)-1;
rois(:,:,a+1:a+b) = ROIsFromGUI(:,:,2:b+1);
ROIkeeps(a+1:a+b)=1;
ROIkeeps(r)=0;
%% Delete ROIs that we don't want to keep
rois=rois(:,:,ROIkeeps>0);
%% Get time courses
tc=kyoGetTCs(mov,rois);
imagesc(tc')