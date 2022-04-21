%% patch 50 analysis

thresh = ones(size(rois,3),1);

%% get the timing for the stim

stimTrace=zeros(1,size(tc,1));
for i=1:numel(Scenes)
    if strcmp(Scenes(i).stim,'patch50')
        stimTrace(Scenes(i).fStart:Scenes(i).fEnd)=1;
    end
end
clear i

%% plot all of the traces, to inspect threshold
roiSet = [2 15];

numRois = numel(roiSet);
for n=1:numRois
    r=roiSet(n);
    subplot(numRois,1,n)
    
    area(stimTrace.*max(tc(:,r)),'FaceColor',[0.9 0.9 0.9],'LineStyle','none');
    
    hold on
    plot([0 size(tc,1)],[thresh(r) thresh(r)],'--k')
    area((tc(:,r)>thresh(r)).*thresh(r),'FaceColor','red','LineStyle','none');
    plot(tc(:,r));
    
    hold off
    axis([0 size(tc,1) -0.5 max(tc(:,r))]);
    set(gca,'xtick',[]);
    title(sprintf('ROI %i',r))
end

clear r n numRois roiSet

%% view stimulus-triggered averages to pick the response window

baseline = 3;
fullwidth = 10;
responses = kyoResponses(tc,Scenes,baseline,fullwidth);

% plotting
figure
for r=1:size(rois,3)
    subplot(5,6,r)
    
    rectangle('Position',[baseline 0 2 1],'FaceColor',[0.9 0.9 0.9],'LineStyle','none')
    hold on
    
    % individual traces
    %plot(squeeze(responses(r).raw(:,1,:)))
    
    % mean and sem
    boundedline((1:fullwidth),squeeze(responses(r).mean(:,1,:)),squeeze(responses(r).sem(:,1,:)))
    
    hold off
    title(sprintf('ROI %i',r))
    axis([0 fullwidth 0 1])
end

%% clean up
clear baseline fullwidth responses
%% detect responses

baseline = 0;
fullwidth = 3;
responses = kyoResponses(tc,Scenes,baseline,fullwidth);

for r=1:numel(responses)
    resp = responses(r).raw;
    for rep=1:numReps
        binary_responses(r,rep)=max(resp(:,1,rep)>thresh(r));
    end
end

imagesc(binary_responses)
clear r resp baseline fullwidth responses rep
%% calculate stats
%total_responses = sum(sum(binary_responses));
fraction_of_cells_resp_per_rep = sum(binary_responses) ./ size(rois,3);

mean_resp_fraction = mean(fraction_of_cells_resp_per_rep);
