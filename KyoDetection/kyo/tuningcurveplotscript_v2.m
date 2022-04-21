
figure('units','normalized','outerposition',[0 0 .8 1])
r=1;
panel=1;
while panel < 60
    
    if (tuningCurves(r).p < 0.01) && (tuningCurves(r).peak > 2)
        subplot(5,12,panel)
        panel=panel+1;
        
        m = tuningCurves(r).mean;
        s = tuningCurves(r).sem;
        
        numStim = numel(m);
        h = numStim/2;
        
        hp = polar((0:numStim).*pi/4,[m;m(1)]');
        
        theta1 = [(0:h).*pi/4 (h:-1:0).*pi/4];
        rad1 = [m(1:h+1)+s(1:h+1);m(h+1:-1:1)-s(h+1:-1:1)]';
        
        theta2 = [(h:numStim).*pi/4 (numStim:-1:h).*pi/4];
        rad2 = [m(h+1:numStim)+s(h+1:numStim);m(1)+s(1);m(1)-s(1);m(numStim:-1:h+1)-s(numStim:-1:h+1)]';
        
        [x,y]=pol2cart(theta1,rad1);
        patch(x,y,[0.9 0.9 1.0], 'FaceAlpha',0.9,'LineStyle','none')
        [x,y]=pol2cart(theta2,rad2);
        patch(x,y,[0.9 0.9 1.0], 'FaceAlpha',0.9,'LineStyle','none')
        
        %delete(findall(ancestor(hp,'figure'),'HandleVisibility','off','type','line'));
        %delete(findall(ancestor(hp,'figure'),'HandleVisibility','off','type','line','-or','type','text'));
        
        %title(['r ' num2str(roiSet(i)) ': max=' num2str(max(m))])
        %title(['r ' num2str(roiSet(i)) ': p=' num2str(anova1(tuningCurves(roiSet(i)).raw',[],'off'))])
        title(sprintf('r%i:p=%0.3f,m=%0.1f',r,tuningCurves(r).p,tuningCurves(r).peak))
    end
    r=r+1;
end