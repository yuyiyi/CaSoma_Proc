function kyoDisplaySingleResponse(responses,roi,bl,stimDuration)

resp = responses(roi);
numStim=size(resp.mean,2);
numReps=size(resp.raw,3);
fw = size(resp.mean,1);

figure('units','normalized','outerposition',[0.1 0.1 .4 .6])

% plot individual responses
k=resp.raw(:);
maxY=max(k).*1.3;
maxY=max(1,maxY);

p=1;
for rep=1:numReps
    for stim=1:numStim
        subplot(numReps+1,numStim,p)
        rectangle('Position',[bl -1 stimDuration maxY+1],'FaceColor',[0.90 0.90 0.90],'LineStyle','none')
        hold on
        plot([1 fw],[0 0],'--k')
        plot(resp.raw(:,stim,rep))
        axis([1 fw -1 maxY])
        
        if p==1
            title(sprintf('ROI: %i',roi))
        else
            set(gca,'XTick',[])
            set(gca,'YTick',[])
        end
        hold off
        p=p+1;
    end
end

% plot mean+/- sem
maxY=max(max(resp.mean)).*1.3;
maxY=max(1,maxY);

for stim=1:numStim
    subplot(numReps+1,numStim,p)
    rectangle('Position',[bl -1 stimDuration maxY+1],'FaceColor',[0.90 0.90 0.90],'LineStyle','none')
    hold on
    plot([1 fw],[0 0],'--k')
    boundedline(1:fw,resp.mean(:,stim),resp.sem(:,stim))
    axis([1 fw -1 maxY])
    set(gca,'XTick',[])
    hold off
    p=p+1;
end

