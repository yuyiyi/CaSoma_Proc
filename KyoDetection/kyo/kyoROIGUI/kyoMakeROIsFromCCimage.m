function [rois,regions]=kyoMakeROIsFromCCimage(ccimage,minArea,displayit)

bw=adaptivethreshold(ccimage,[100 100],-.1,0); % numbers determined emperically

if nargin<2
    displayit=0;
end

regions=bwlabeln(bw);
s=regionprops(regions);

roiNum=1;
for r=1:max(regions(:))
   if s(r,1).Area<minArea
       regions(regions==r)=0;
   else
       rois(:,:,roiNum)=double(regions==r);
       roiNum=roiNum+1;
   end
end

regions_th=regions>0;
regions=bwlabeln(regions_th);

if displayit==1
    figure
    subplot(1,3,1)
    imagesc(ccimage)
    axis square off
    subplot(1,3,2)
    imagesc(bw)
    axis square off
    subplot(1,3,3)
    imagesc(regions)
    axis square off
end
