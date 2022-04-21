function tc = kyoGetTCs(mov,rois)
tic
tc = zeros(size(mov,3),size(rois,3));
for r=1:size(rois,3)
    roi=rois(:,:,r);
    df = squeeze(sum(sum(bsxfun(@times,roi,mov),1),2))./sum(roi(:));
    f = quantile(df,0.1);
    if f==0
        f=0.5;
    end
    tc(:,r) = (df./f)-1;
end
toc
