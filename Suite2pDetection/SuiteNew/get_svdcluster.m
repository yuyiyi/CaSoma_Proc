function [ops, stat, res] = get_svdcluster(ops, RegPara, metadata)
if isfield(RegPara, 'RegImgsize')
    Ly  =  RegPara.RegImgsize(1);
    Lx  =  RegPara.RegImgsize(2);
else
    Ly = size(RegPara.mimg,1);
    Lx = size(RegPara.mimg,2);    
end
ntotframes = metadata.numframe;
ops.NavgFramesSVD  = min(ops.NavgFramesSVD, ntotframes);
nt0 = max(ceil(ntotframes / ops.NavgFramesSVD), ops.nfave); % number of frames to average
ops.NavgFramesSVD = floor(ntotframes/nt0);

fid = fopen(RegPara.RegFile, 'r');
data = fread(fid,  Ly*Lx*ntotframes, [RegPara.RawPrecision, '=>', RegPara.RawPrecision]);
data = reshape(data, Ly, Lx, []);
irange = 1:nt0*floor(size(data,3)/nt0);
if irange(end)<ntotframes
    data(:,:,irange(end)+1:ntotframes) = [];
end

tic
mov = zeros(Ly, Lx, ops.NavgFramesSVD, 'single');
ix = 0;
while ix<irange(end)/nt0
    if (ix+100)*nt0<=irange(end) % batch size 100 (compute 100 average image at a time)
        data1 = reshape(data(:,:,ix*nt0+1:(ix+100)*nt0), Ly, Lx, nt0, []);
    else
        data1 = reshape(data(:,:,ix*nt0+1:end), Ly, Lx, nt0, []);
    end
        davg = single(squeeze(mean(data1,3)));
        clear data1
        davg = davg - repmat(mean(davg,3), 1, 1, size(davg,3));
        mov(:,:,ix + (1:size(davg,3))) = davg;
        ix = ix + size(davg,3);
        clear davg            
end
fclose(fid);
clear data
toc

%%
mov(:, :, (ix+1):end) = [];
% if exist(RegPara.yrange)
%     mov = mov(RegPara.yrange, RegPara.xrange, :);
% end
[c,r,~] = size(mov);

%% SVD options
ops.nSVDforROI = min(ops.nSVDforROI, size(mov,3));
% gaussian smooth
if ops.sig>0.05
	for i = 1:size(mov,3)
	   I = mov(:,:,i);
	   I = my_conv(my_conv(I',ops.sig)', ops.sig);
	   mov(:,:,i) = single(I);
	end
end

%% SVD
clear res stat
if isfield(RegPara, 'RegImgsize')
    res.Ly  =  RegPara.RegImgsize(1);
    res.Lx  =  RegPara.RegImgsize(2);
else
    res.Ly = size(RegPara.mimg,1);
    res.Lx = size(RegPara.mimg,2);    
end
    mov = reshape(mov, [], size(mov,3));
if min([c,r])>=1000
    [ymesh, xmesh] = meshgrid(1:Lx,1:Ly);
    block1 = round(Ly/1000);
    block2 = round(Lx/1000);
    c1 = ceil(Ly/block1);
    r1 = ceil(Lx/block2);
    xmesh = ceil(xmesh/c1);
    ymesh = ceil(ymesh/r1);   
    iclust = zeros(res.Ly,res.Lx); 
    M = zeros(res.Ly,res.Lx); 
    Nclust = 0;    
    for xi = 1:max(xmesh(:))    
        for yi = 1:max(ymesh(:))
            mov1 = mov(xmesh(:)==xi & ymesh(:)==yi,:); 
            mov1 = mov1./repmat(mean(mov1.^2,2).^.5, 1, size(mov1,2));
            flag = zeros(Ly,Lx);
            flag(xmesh==xi & ymesh==yi) = 1;
            cc = max(sum(flag));
            rr = max(sum(flag,2));
            [ops, U, Sv, V] = getSVDcomponents(ops, mov1);
            U = reshape(U, cc, rr,[]);
            [ops, restmp] = svd_cluster(ops, cc, rr, U, Sv);
            tmpclust = restmp.iclust + Nclust;
            tmpclust = reshape(tmpclust, cc, rr);
            iclust(flag==1)  = tmpclust;     
            Mtmp = reshape(restmp.M,cc,rr);
            M(flag==1) = Mtmp;
            Nclust = max(tmpclust(:));
        end
    end
    res.iclust = reshape(iclust,[],1);
    res.M = reshape(M, 1, []);
    stat = get_stat(res);
else
    mov = mov./repmat(mean(mov.^2,2).^.5, 1, size(mov,2));
    [ops, U, Sv, V] = getSVDcomponents(ops, mov);
%     U = reshape(U, Ly, Lx,[]);
    [ops, res] = svd_cluster2(ops, Ly, Lx, U, Sv);
    stat = get_stat(res);                        
end

