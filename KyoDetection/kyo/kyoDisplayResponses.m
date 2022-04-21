function kyoDisplayResponses(responses,baseline,stimduration,perpage)

a = responses(1).raw;
numStim = size(a,2);
fw = size(a,1);
numRois = numel(responses);

bl = baseline;
stimDur = stimduration;

if nargin<4
    perpage=20;
end
rs = perpage;

offset = 2;

maxX = (offset+fw)*numStim;
x=1:fw;

r1 = 1;
r2 = 1;

while r2<numRois
    r2 = r1 + (rs - 1);
    
    figure('units','normalized','outerposition',[0 0 .5 1])

    for r=r1:min(r2,numRois)
        subplot(rs,1,r-r1+1)
        
        maxY=max(max(responses(r).mean)).*1.3;
        maxY=max(1,maxY);
        rectangle('Position',[bl 0 stimDur maxY],'FaceColor',[1 1 1],'LineStyle','none')
        
        boundedline(x,responses(r).mean(:,1),responses(r).sem(:,1))
        axis([0 maxX 0 maxY.*1.3])
        hold on
        for s=2:numStim
            rectangle('Position',[bl+((s-1)*(fw+offset)) 0 stimDur maxY],'FaceColor',[1 1 1],'LineStyle','none')
            boundedline(x+((s-1)*(fw+offset)),responses(r).mean(:,s),responses(r).sem(:,s));
        end
        axis off
        title(sprintf('ROI: %i',r))

    end
    
    r1 = r2 + 1;
end