function tuningCurves = kyoTuningCurves(responses,bl,st,tail)

if nargin<4
    tail=0;
end

resp = responses(1);
numStim=size(resp.mean,2);
numReps=size(resp.raw,3);

for r=1:numel(responses)
    curve=zeros(numStim,numReps);
    for s=1:numStim
        for rep=1:numReps
            curve(s,rep) = max(responses(r).raw(bl:bl+st+tail,s,rep));
        end
    end
    tuningCurves(r).raw = curve;
    tuningCurves(r).mean = mean(curve,2);
    tuningCurves(r).peak = max(mean(curve,2));
    tuningCurves(r).sem = std(curve,0,2)/sqrt(numReps);
    tuningCurves(r).p = anova1(curve',[],'off');

end
