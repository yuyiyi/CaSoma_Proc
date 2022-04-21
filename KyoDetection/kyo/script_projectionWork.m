%% working on projections

mov = mov2(:,:,1:end);

movMean = mean(mov,3);
movStd = std(mov,0,3);
movMax = max(mov,[],3);
movKurt = kurtosis(mov,0,3);

%%
G = fspecial('gaussian',[4 4],2);

for f=1:size(mov,3)
movF(:,:,f) = imfilter(mov(:,:,f),G,'same');
end

movKurt2 = kurtosis(movF,0,3);

%%
figure
subplot(1,5,1)
imagesc(movMean)
axis square off
subplot(1,5,2)
imagesc(movStd)
caxis([0 20])
axis square off
subplot(1,5,3)
imagesc(movMax)
caxis([0 100])
axis square off
subplot(1,5,4)
imagesc(ccimage1)
caxis([0 1])
axis square off
subplot(1,5,5)
imagesc(movKurt1)
caxis([0 20])
axis square off
colormap gray
%%
minArea = 5;
[rois1]=kyoMakeROIsFromCCimage(movKurt1,minArea,1,[20 20 -0.03]);
%%
thresh=4;
[roisTh1,tc1]=kyoScreenKurt(rois1,mov1,thresh);