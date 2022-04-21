function [ops, U, Sv, V] = getSVDcomponents(ops, mov)
COV = mov' * mov/size(mov,1);
ops.nSVDforROI = min(size(COV,1)-2, ops.nSVDforROI);

if ops.useGPU && size(COV,1)<1.2e4
    reset(gpuDevice); 
    g = gpuDevice; 
    disp(g.FreeMemory);
    [V, Sv, ~]      = svd(gpuArray(double(COV)));
    V               = single(V(:, 1:ops.nSVDforROI));
    Sv              = single(diag(Sv));
    Sv              = Sv(1:ops.nSVDforROI);
    %
     Sv = gather(Sv);
     V = gather(V);
    reset(gpuDevice); 
    g = gpuDevice; 
%     disp(g.FreeMemory);
else
    [V, Sv]          = eigs(double(COV), ops.nSVDforROI);
    Sv              = single(diag(Sv));
end

U               = normc(mov * V);
U               = single(U);
