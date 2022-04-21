function [tcraw, tc, tcraw_pca, tc_pcasub, rois] = kyoGetTCs_sutract_pca_v2(mov, rois, subtractPara)

if ndims(mov)==3
    [d1,d2,T] = size(mov);
    mov = reshape(mov, d1*d2,T);
else
    [~,T] = size(mov);
end
tic
lowSignal=0;
rg=1; 
roiall = rois;
tcraw = zeros(T,max(rois(:)));
tc = zeros(T,max(rois(:)));
tc_pcasub = zeros(T,max(rois(:)));
tcraw_pca = zeros(T,max(rois(:)));

for r=1:max(rois(:))
    roitmp=zeros(size(rois));
    roitmp(rois==r) = 1;
    r1 = subtractPara(1);
    r2 = subtractPara(2); 
    if r1>0
        dila1 = bwmorph(roitmp,'dilate', r1);
    else 
        dila1 = roitmp;
    end
    siglist = []; 
    bglist = [];
    siglist = mov(roitmp==1,:)';
    while isempty(bglist)
        dila2 = bwmorph(roitmp,'dilate', r2);
        subbg1 = dila2 - dila1; 
        subbg = and(subbg1, ~roiall);    
        bglist = mov(subbg==1,:)';    
        r2 = r2+1;
        %     [U,S,~,~,~,mu] = pca(double(bglist));
    end    
    [U,S,~,~,~,mu] = pca(double(bglist),'Algorithm', 'SVD','NumComponents', 1);
    recontrace = mean(S(:,1)*U(:,1)',2);
    df = mean(siglist,2)- recontrace;
    df1 = mean(siglist,2);
    
    tcraw(:,rg) = df1;
    f = quantile(df1,0.4); % This seems to work nicely for most signals, but it may need to be changed for highly active cells
        if f==0 % in case of very weak signal, use the mean instead
            lowSignal=lowSignal+1;
            tc(:,rg) = (df1./mean(df1))-mean(df1);
        else
            tc(:,rg) = (df1./f)-1;
        end
        
        tcraw_pca(:, rg)=df;
        f = quantile(df,0.4); % This seems to work nicely for most signals, but it may need to be changed for highly active cells
        if f==0 % in case of very weak signal, use the mean instead
            lowSignal=lowSignal+1;
            tc_pcasub(:,rg) = (df./mean(df))-mean(df);
        else
            tc_pcasub(:,rg) = (df./f)-1;
        end
        rg = rg+1;
end
toc
if lowSignal>0
    fprintf('%i ROI(s) had weak signals.',lowSignal);
end

