function out = kyoGetCellMask(in)

% five passes of a Kuwahara filter
out = KuwaharaFast(in, 1);
for n=1:8
    out = KuwaharaFast(out, 1);
end

% binarize based on central value
sz=size(in);
cx=round(sz(1)/2);
cy=round(sz(2)/2);
out = out > (0.7*out(cx,cy));

% if there is more than one region, then...
regions=bwlabeln(out);
s=regionprops(regions);
sz=size(s);
dist=zeros(sz(1));
if sz(1)>1
   % ...trim the other regions, leaving only the most central one
   for r=1:sz(1)
       dist(r)=sqrt( (s(r).Centroid(1)-cy)^2 + (s(r).Centroid(2)-cx)^2);
   end
   dist=dist(:,1);
   keepRegion=(dist==min(dist));
   for r=1:sz(1)
       if keepRegion(r)~=1
           regions(regions==r)=0;
       end
   end
   out=regions>0;
end
% 
% % now trim the outer j layers of pixels
% out=bwmorph(out,'majority');
% out=bwmorph(out,'skel',1);
