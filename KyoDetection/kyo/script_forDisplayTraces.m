%% 1
figure
numRois = size(tc,2);

for r=1:numRois
    subplot(numRois,1,r)
    plot(tc(:,r))
    axis off
end
%% 2
figure
numRois = size(tc,2);
offset = 1;
for r=1:numRois
    plot(tc(:,r)+(offset*r));hold on
    axis off
end
%% 3