function [tcraw,tc,roisGood] = kyoGetTCs(mov,rois,kurtosisThresh)

if nargin<3
    kurtosisThresh=0;
end

tic
lowSignal=0;
%tc = zeros(size(mov,3),size(rois,3));
rg=1;
for r=1:size(rois,3)
    
    roi=rois(:,:,r);
    df = squeeze(sum(sum(bsxfun(@times,roi,mov),1),2))./sum(roi(:));
    
    if kurtosis(df) > kurtosisThresh
        roisGood(:,:,rg)=roi;
        tcraw(:, rg)=df;
        f = quantile(df,0.4); % This seems to work nicely for most signals, but it may need to be changed for highly active cells
        if f==0 % in case of very weak signal, use the mean instead
            lowSignal=lowSignal+1;
            tc(:,rg) = (df./mean(df))-mean(df);
        else
            tc(:,rg) = (df./f)-1;
        end
        rg = rg+1;
    end
    
end
toc
if lowSignal>0
    fprintf('%i ROI(s) had weak signals.',lowSignal);
end
