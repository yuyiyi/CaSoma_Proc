function [roisOut,tcOut]=kyoScreenKurt(rois,mov,thresh)

tic

for r=1:size(rois,3)
    roi = rois(:,:,r);
    tcRaw(:,r) = squeeze(sum(sum(bsxfun(@times,roi,mov),1),2))./sum(roi(:));
    k(r) = kurtosis(tcRaw(:,r));
    if mod(r,100)==0
        fprintf(1,'On %i...\n',r)
    end
end
roisGood=rois(:,:,k>thresh);
toc

tc=kyoGetTCs(mov,roisGood);

figure
numRois = size(tc,2);
offset = 1;
for r=1:numRois
    plot(tc(:,r)+(offset*r));hold on
    axis off
end

roisOut = roisGood;
tcOut = tc;