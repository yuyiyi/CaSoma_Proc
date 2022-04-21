%% draw oris from Scenes and tc

roiSet = [81:90];
win1 = 2; % window at start of stim
win2 = 4; % window at end of stim
figure

for r=1:numel(roiSet)
    for s=1:numStim
        subplot(numel(roiSet),numStim,((r-1)*numStim)+s);
        
        % Collect all of the traces (all reps for this roi and stim)
        rep=1;
        for n=1:numel(Scenes)
            if strcmp(Scenes(n).stim,stimNames{s})
                traces{rep} = tc(Scenes(n).fStart-win1:Scenes(n).fEnd+win2,roiSet(r));
                rep=rep+1;
            end
        end
        
        % Keep track of the max and min Y
        if s==1
            minY=min(traces{1});
            maxY=max(traces{1});
        end
        
        % Ensure that they're all the same length
        maxLength = numel(traces{1});
        for rep=2:numReps
            maxLength=max(maxLength,numel(traces{rep}));
            minY=min(minY,min(traces{rep}));
            maxY=max(maxY,max(traces{rep}));
        end
        
        % Copy the data to a matrix (from the cell array)
        traces2=ones(maxLength,numReps);
        for rep=1:numReps
            traces2(1:numel(traces{rep}),rep)=traces{rep};
        end
        
        % Get the mean
        traces_mean=mean(traces2,2);
        
        % Plot it all
        h=plot(1:maxLength,ones(maxLength,numReps+1));
        
        rectangle('Position',[win1,0,maxLength-(win1+win2),100],'FaceColor',[0.9 0.9 0.95],'EdgeColor','none')
        
        for rep=1:numReps
            set(h(rep),'x',1:maxLength,'y',traces2(:,rep),'Color',[0.7 0.7 0.7]);
        end
        
        set(h(numReps+1),'x',1:maxLength,'y',traces_mean,'Color','black','LineWidth',2);
        
        uistack(h,'up') % move the traces to the top and the rect to the back
        
        % labels
        if r==1
            title(stimNames{s},'FontSize',9)
        end
        if s==1
            ylabel(['ROI ' num2str(roiSet(r))],'FontSize',9)
        end
        
        %axis off
    end
    
    % set all of the axes the same
    for s=1:numStim
        subplot(numel(roiSet),numStim,((r-1)*numStim)+s);
        axis([0 maxLength minY maxY]);
    end
end
set(gcf,'Color',[1 1 1]);   % set background to white

clear r s h maxLength rep traces traces2 win1 win2 n traces_mean roiSet maxY minY