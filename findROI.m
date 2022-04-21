function roikeep = findROI(stat, roi_kurt, data, RegPara, SVDROIPara, res)
d1 = size(data,1);
d2 = size(data,2);
ROI_reg = ones(d1,d2);

if ~isempty(RegPara)
    if isfield(RegPara, 'xrange')
        xrange = RegPara.xrange;
        yrange = RegPara.yrange;
        ROI_reg(setdiff(1:d1,xrange),:) = 0;
        ROI_reg(:,setdiff(1:d2,yrange)) = 0;
    end
end

data = reshape(data, d1*d2,[]);
t = squeeze(mean(data,1));
t = smooth(t,5,'moving');
fieldmean = (t-min(t))/(max(t)-min(t));

corr_rand = [];
for p = 1:100
    corr_rand(p) = quantile(corr(single(data(ceil(rand(100)*d1*d2),:)'),single(mean(data)')), 0.75);
end
corr_thresh = mean(corr_rand);
M = reshape(res.M, d1, d2);
lambdath = quantile(M(:), 0.4);
% if isfield(SVDROIPara, 'lambdath')
%     lambdath = SVDROIPara.lambdath;
% else
%     lambdath = 0.02;
% end
% if isfield(SVDROIPara, 'corr_thresh')
%     corr_thresh = SVDROIPara.corr_thresh;
% else
%     corr_thresh = 0.26;
% end

roi_corr = single(zeros(d1*d2,1));
roi_id = int16(zeros(d1*d2,1));
roiflag = zeros(d1,d2);
k=1; mean_corr = [];

% update rois from stat
for ii = 1:length(stat)
    pxid = stat(ii).ipix;
    pxv = stat(ii).lambda;
    if quantile(pxv, 0.9)<lambdath
        continue
    end
    pxid(pxv<lambdath) = [];
    roi1 = zeros(d1,d2);
    roi1(pxid)=1;
    roi1 = roi1.*ROI_reg;
    bw = bwmorph(roi1,'clean');
    bw = bwlabel(bw);
    if max(bw(:))>0
        for j = 1:max(bw(:))
            [a,b] = find(bw==j);
            li = sub2ind([d1,d2], a,b);
            t = data(li,:);
            c = corr(single(t'), mean(single(t'),2));
            li(c<corr_thresh) = [];
            c(c<corr_thresh) = [];
            if length(li)>SVDROIPara.minarea/2 && length(li)<SVDROIPara.maxarea
                roi_corr(li) = c;
                roi_id(li)  = k; 
                mean_corr(k) = mean(c); 
                roiflag(li) = roiflag(li)+1;
                k = k+1;
            end
        end
    end
end
% figure, imshow(reshape(roi_corr,d1,d2), []), colorbar
% update rois from kurtosis, add those were not identified from suite2p
if ~isempty(roi_kurt)
%     roi_kurt = bwlabel(roi_kurt);
    roiResidual = roi_kurt.*[1-roiflag];
    if max(roiResidual(:))>0
        ii = unique(roiResidual(:));
        ii(ii==0) = [];
        for i = 1:length(ii)
            id = ii(i);
            roitmp = zeros(size(roi_kurt));
            roitmp(roi_kurt==id) = 1;
            roistat = regionprops(roitmp, 'centroid');            
            if roiflag(ceil(roistat(1).Centroid(2)),ceil(roistat(1).Centroid(1))) == 0
                roi_id(roitmp==1) = k; 
                roiflag(roitmp==1) = roiflag(roitmp==1)+1;
                k = k+1;
            end                
        end
    end
end

roi_id = reshape(roi_id, d1, d2);
roi_id(roiflag>1) = 0;
roi_snr = zeros(size(roi_id));
data = reshape(data, d1*d2,[]);
k = 1; sn = []; amp = [];
roikeep = zeros(size(roi_id)); 
for i = 1:max(roi_id(:))
    roitmp = zeros(d1,d2);
    roitmp(roi_id==i) = 1;
    bw = bwmorph(roitmp,'clean');
    if sum(bw(:)) > SVDROIPara.minarea && max(bw(:))>=1 
        bw = bwlabel(bw);
        s = regionprops(bw);
        for j = 1:length(s)
            rr = s(j).BoundingBox(3)./s(j).BoundingBox(4);
            rr = max(rr,1/rr);
            if s(j).Area > SVDROIPara.minarea && rr < 5
                [a,b] = find(bw==j);
                li = sub2ind([d1,d2], a,b);                
                t = data(li,:);
                % SNR
                t = mean(t)';                
                snr1 = (max(t)-mean(t))/std(t(t<quantile(t,0.6)));
                sn(i) = snr1;
                roi_snr(li) = snr1;
                dff = t-quantile(t, 0.4);
                if snr1>5 && max(dff)>=abs(min(dff))
                    roikeep(li) = k;
                    k = k+1;
                end
            end
        end
    end
end

