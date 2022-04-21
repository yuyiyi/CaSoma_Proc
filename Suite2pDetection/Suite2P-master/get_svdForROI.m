function [ops, U, Sv, V] = get_svdForROI(ops)

% iplane = ops.iplane;

[Ly, Lx] = size(ops.mimg1);

ntotframes          = ceil(sum(ops.Nframes));
ops.NavgFramesSVD   = min(ops.NavgFramesSVD, ntotframes);
nt0 = ceil(ntotframes / ops.NavgFramesSVD);


ops.NavgFramesSVD = floor(ntotframes/nt0);
nimgbatch = nt0 * floor(2000/nt0);

ix = 0;
fid = fopen(ops.RegFile, 'r');

mov = zeros(Ly, Lx, ops.NavgFramesSVD, 'single');

while 1
    data = fread(fid,  Ly*Lx*nimgbatch, '*int16');
    if isempty(data)
       break; 
    end
    data = single(data);
    data = reshape(data, Ly, Lx, []);
    
%     data = data(:,:,1:30:end);
    % subtract off the mean of this batch
    data = data - repmat(mean(data,3), 1, 1, size(data,3));
    
    irange = 1:nt0*floor(size(data,3)/nt0);
    data = data(:,:, irange);
    
    data = reshape(data, Ly, Lx, nt0, []);
    davg = single(squeeze(mean(data,3)));
      
    mov(:,:,ix + (1:size(davg,3))) = davg;
        
    ix = ix + size(davg,3);    
end
fclose(fid);
%%
mov(:, :, (ix+1):end) = [];

mov = mov(ops.yrange, ops.xrange, :);
% mov = mov - repmat(mean(mov,3), 1, 1, size(mov,3));
%% SVD options

ops.nSVDforROI = min(ops.nSVDforROI, size(mov,3));

% smooth
if ops.sig>0.05
	for i = 1:size(mov,3)
	   I = mov(:,:,i);
	   I = my_conv(my_conv(I',ops.sig)', ops.sig);
	   mov(:,:,i) = I;
	end
end

mov             = reshape(mov, [], size(mov,3));
mov             = mov./repmat(mean(mov.^2,2).^.5, 1, size(mov,2));
COV             = mov' * mov/size(mov,1);

ops.nSVDforROI = min(size(COV,1)-2, ops.nSVDforROI);

if ops.useGPU && size(COV,1)<1.2e4
    [V, Sv, ~]      = svd(gpuArray(double(COV)));
    V               = single(V(:, 1:ops.nSVDforROI));
    Sv              = single(diag(Sv));
    Sv              = Sv(1:ops.nSVDforROI);
    %
     Sv = gather(Sv);
     V = gather(V);
else
    [V, Sv]          = eigs(double(COV), ops.nSVDforROI);
    Sv              = single(diag(Sv));
end

U               = normc(mov * V);
U               = single(U);

%
U = reshape(U, numel(ops.yrange), numel(ops.xrange), []);
if ~exist(ops.ResultsSavePath, 'dir')
   mkdir(ops.ResultsSavePath); 
end
if getOr(ops, {'writeSVDroi'}, 0)
    save(sprintf('%s/SVDroi_%s_%s_plane%d.mat', ops.ResultsSavePath, ...
        ops.mouse_name, ops.date, ops.iplane), 'U', 'Sv', 'V', 'ops');
end
