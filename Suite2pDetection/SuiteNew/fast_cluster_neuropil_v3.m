function [ops, stat, res] = fast_cluster_neuropil_v3(ops, mimg, U, Sv)
U =  reshape(U, [], size(U,ndims(U)));
for i = 1:size(U,2)
  U(:,i) = U(:,i)  * Sv(i).^.5;
end
U = U';
[nSVD, Npix] = size(U);

%% clustering options
Ly = size(mimg,1);
Lx = size(mimg,2);
ops.Nk0 = floor(sqrt(ops.Nk0))^2;
Nk = ops.Nk0;
nsqrt = round(sqrt(Nk));

xs = repmat(round(linspace(1, nsqrt, Lx)), Ly, 1);
ys = repmat(round(linspace(1, nsqrt, Ly))', 1, Lx);
% iclust = xs + (ys-1) * nsqrt; 
iclust = ceil(rand(Ly, Lx)*Nk);

clear xs ys
niter   = ops.niterclustering;
%%
if ops.ShowCellMap
%     figure( 'Units', 'pixels', 'position', [100 100 900 900])
%     colormap('hsv')
%     axes('position', [.05 .05 .925 .925])
%     set(gcf, 'Color', 'w')
    scrsz = get(groot,'ScreenSize');
    if isempty(findobj('type','figure','number',10))
        pos = round([10 20 scrsz(4)*0.9 scrsz(4)*0.9]);
    else
        h1_handles = get(figure(10));
        pos = h1_handles.Position;
    end        
    h1 = figure(10);
    clf('reset')
    set(h1,'Name','Suit2p results','Position',pos);
    colormap('hsv')
    axes('position', [.05 .05 .925 .925])
end

r   = rand(1, Nk);
Sat = ones(Ly, Lx);

err = zeros(niter,1);
ops.meanV = gather(sum(Sv)/(Ly*Lx));
Nk = ops.Nk0;
Nkiter = round(linspace(ops.Nk0, ops.Nk, niter-2));
Nkiter(end+1:(niter+1)) = ops.Nk;

%%
M = .0001 * ones(1, Npix, 'single');
ison = true(Nk,1);
nBasis = 10;
xc = linspace(1, Lx, nBasis);
yc = linspace(1, Ly, nBasis);
yc = yc';
xs = 1:Lx;
ys = 1:Ly;
sigx = 4*(Lx - 1)/nBasis;
sigy = 4*(Ly - 1)/nBasis;
S = zeros(Ly, Lx, nBasis, nBasis, 'single');
for kx = 1:nBasis
    for ky = 1:nBasis
        cosx = 1+cos(2*pi*(xs - xc(kx))/sigx);
        cosy = 1+cos(2*pi*(ys - yc(ky))/sigy);
        cosx(abs(xs-xc(kx))>sigx/2) = 0;
        cosy(abs(ys-yc(ky))>sigy/2) = 0;       
        S(:, :,ky, kx) = cosy' * cosx;
    end
end
S = reshape(S, [], nBasis^2);
S = normc(S);

%%
StS = S' * S;
StU = S' * U';
LtL = zeros(Nk, Nk, 'single');
LtU = zeros(Nk, nSVD, 'single');
LtS = zeros(Nk, nBasis^2, 'single');
Ireg = diag([ones(Nk,1); zeros(nBasis^2,1)]);

tic
for k = 1:niter
    for i = 1:Nk
        ix = find(iclust==i);
        if numel(ix)==0
            LtU(i,:) = 0;
            LtL(i,i) = 0;
            LtS(i,:) = 0; 
        else
            LtU(i,:) = M(ix) * U(:, ix)';
            LtL(i,i) = sum(M(ix).^2);
            LtS(i,:) = M(ix) * S(ix, :);
        end
    end
    %
    covL = [LtL LtS; LtS' StS];
    LtXS = [LtU; StU];
    Lam = (covL + 1e-4 * Ireg) \ LtXS;
    vs = normc(Lam(1:Nk, :)');
    neuropil = Lam(Nk + [1:nBasis^2], :)' * S';
    xs = vs' * (U - neuropil);
    [M, iclust] = max(xs,[],1);
    if 1
        %---------------------------------------------%
        xs(iclust + (0:Nk:numel(xs)-1)) = 0;
        [M2, iclust2] = max(abs(xs),[],1);
        
        dM = M - M2;
        indrem = Nkiter(k) - Nkiter(k+1);
        dMk = 0*ones(Nk,1);
        icl = cell(Nk,1);
        for j = 1:Nk
            icl{j} = iclust==j;
            if ~isempty(icl{j})
                dMk(j) = sum(dM(icl{j}));
            end
        end
        
        vlk = zeros(Nk, 1);
        vlk(~ison) = Inf;
        while indrem>0
            [Xmin, imin]          = min(dMk + vlk);
            if isinf(Xmin)
                Nkiter(k+1) = sum(ison);
                break;
            end
            newi               = iclust2(icl{imin});
            iclust(icl{imin})  = newi;
            M(icl{imin})       = M2(icl{imin});
            dMk(unique(newi))  = Inf;
            dMk(imin)          = Inf;
            dMk(unique(iclust(iclust2==imin))) = Inf;
            ison(imin) = 0;
            indrem             = indrem - 1;
        end
    end
    %---------------------------------------------%
    err(k) = sum(M(:));    
    if (rem(k,10)==1 || k==niter) && ops.ShowCellMap
        lam = M;
        for i = 1:Nk
            ix = find(iclust==i);
            nT0 = numel(ix);
            if nT0>0
                vM = lam(ix);
                lam(ix) = vM;
            end
        end
        V = max(0, min(.5 * reshape(lam, Ly, Lx)/mean(lam(:)), 1));
        H = reshape(r(iclust), Ly, Lx);
        rgb_image = hsv2rgb(cat(3, H, Sat, V));
        imagesc(rgb_image)
        axis off
        drawnow
        fprintf('explained variance is %2.6f time %2.2f \n', err(k), toc)
    end
end

lam = M;
for i = 1:Nk
    ix = find(iclust==i);
    
    nT0 = numel(ix);
    if nT0>0
        vM = lam(ix);
        lam(ix) = vM/sum(vM.^2)^.5;
    end
end

%%
newindx = cumsum(ison);
iclust  = newindx(iclust);
Nk      = numel(unique(iclust));
clear res
res.iclust  = iclust;
res.M       = M;
res.S       = S;
res.covL    = covL + 1e-4 * Ireg;
res.lambda  = lam;
res.Ly  = Ly;
res.Lx  = Lx;
stat = get_stat(res);