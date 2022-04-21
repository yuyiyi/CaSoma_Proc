%% trepan paper scripts
% Load imaging data (must be in correct data directory
fn = '7-DualROI1-GoPro.tif';

[mov1,mov2] = kyoLoadStackTIFF(fn,1);

mov1=double(mov1);
mov2=double(mov2);

movKurt1 = kurtosis(mov1,0,3);
movKurt2 = kurtosis(mov2,0,3);

G = fspecial('gaussian',[4 4],2);

for f=1:size(mov1,3)
    movF1(:,:,f) = imfilter(mov1(:,:,f),G,'same');
    movF2(:,:,f) = imfilter(mov2(:,:,f),G,'same');
end

movKurt1 = kurtosis(movF1,0,3);
movKurt2 = kurtosis(movF2,0,3);
%% rois for 1
minArea = 5;
[rois1]=kyoMakeROIsFromCCimage(movKurt1,minArea,1,[20 20 -0.03]);
%% rois for 2
minArea = 5;
[rois2]=kyoMakeROIsFromCCimage(movKurt2,minArea,1,[20 20 -0.03]);
%% thresh for 1
thresh=4;
[roisTh1,tc1]=kyoScreenKurt(rois1,mov1,thresh);
%% thresh for 1
thresh=4;
[roisTh2,tc2]=kyoScreenKurt(rois2,mov2,thresh);