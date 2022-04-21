function responses = kyoResponses(tc,Scenes,baseline,fullwidth)

if nargin<3
    baseline=0;
end

if nargin<4
    fullwidth=10;
end

[stimNames,numReps] = kyoStimNames(Scenes);
numStim = numel(stimNames);

for r=1:size(tc,2) % go through all ROIs
    resp=zeros(fullwidth,numStim,numReps);
    for s=1:numStim
        for rep=1:numReps
            ind = kyoFindStim(Scenes,stimNames{s},rep)
            resp(:,s,rep) = tc(Scenes(ind).fStart-baseline:Scenes(ind).fStart-baseline+fullwidth-1,r);
        end
    end
    responses(r).raw = resp;
    responses(r).mean = mean(resp,3);
    responses(r).sem = std(resp,0,3)./sqrt(numReps);
end
