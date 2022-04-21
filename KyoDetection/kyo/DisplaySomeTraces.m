%% display some traces
rr = [584:603];
figure
for i=1:numel(rr)
    subplot(numel(rr),1,i)
    plot(tc(:,rr(i)))
    axis([1 154 -0.5 1])
    axis off tight  
end
%% Display Traces as image
figure(10);
imagesc(tc', [0, 1]);
%% Display Traces as image
figure(10);
imagesc(tcKeep', [0, 2]);
%imagesc(All_tcKeep', [0, 1]);
%% Keep all
clear tcKeep roisKeep;
tcKeep=tc;
roisKeep=roisGood;
%% Process 'Keeps'
clear tcKeep roisKeep;
j=1;
for i=1:size(ROI_keepToggles, 2)
    if ROI_keepToggles(i)==1;
        tcKeep(:,j)=tc(:,i);
        roisKeep(:,:,j)=roisGood(:,:,i);
        j=j+1;
    end
    if ROI_keepToggles(i)==0;
        j=j;
    end
end
%% ROI projection
ROIprojection = sum(roisKeep, 3);
figure; 
imagesc(ROIprojection);
axis('square', 'off');
colormap('gray');

figure; 
imagesc(ROIprojection);
axis('square', 'off');
colormap('gray');
colormap(flipud(colormap));
%% All
All_tcKeep = cat(2,tcKeep11, tcKeep21,tcKeep31,tcKeep41);
%% 
figure; 
imagesc(ROIprojection);
axis('square', 'off');
colormap('gray');
