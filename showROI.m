function showROI(Ly, Lx, ROImap, Img)
Img = Img+0.1;
Sat = ones(Ly, Lx)*1;
r = [0.1, rand(1,max(ROImap(:)))];
% ROImap = im2bw(sum(ROImap,3));
H = reshape(r(ROImap+1), Ly, Lx);
Sat(ROImap==0) = 0;    
rgb_image = hsv2rgb(cat(3, H, Sat, Img));
imagesc(rgb_image)
axis off
drawnow