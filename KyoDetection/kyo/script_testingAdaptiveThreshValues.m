%% 1
bw=adaptivethreshold(ccimage,[6 6],-.05,0);
regions=bwlabeln(bw);
s=regionprops(regions);
regions=bwlabeln(regions);
imagesc(regions)
axis square off