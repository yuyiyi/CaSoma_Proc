%% display responses

r1=61;
r2=70;
numr=r2-r1+1;
figure('units','normalized','outerposition',[0 0 1 1])
l=0;
for r=r1:r2
    l=l+1;
    for s=1:numel(stimNames)
        subplot(numr,numel(stimNames),s+(((l-1)*(numel(stimNames)))))
        boundedline(1:12,responses(r).mean(:,s),responses(r).sem(:,s))
        axis([0 12 0 10])
    end
    title(sprintf('ROI:%i',r))
end

%% version 2
numStim = numel(stimNames);

offset = 2;
fw = 12;

x  = 1:fw;
x1 = x;
for s=2:numStim
   x1(end+1:end+fw)=x+((s-1)*(fw+offset));
end

y1=responses(1).mean(:,1);
for s=2:numStim
   y1(end+1:end+fw)=responses(1).mean(:,s);
end
%% version 3

numStim = numel(stimNames);
offset = 2;
fw = 12;
bl=4;
stimDur=5;

x=1:fw;
maxY=max(max(responses(1).mean));
   rectangle('Position',[bl 0 stimDur maxY*1.3],'FaceColor',[1 1 1],'LineStyle','none')

boundedline(x,responses(1).mean(:,1),responses(1).sem(:,1))
axis([0 112 0 maxY.*1.3])
hold on
for s=2:numStim
   rectangle('Position',[bl+((s-1)*(fw+offset)) 0 stimDur maxY*1.3],'FaceColor',[1 1 1],'LineStyle','none')
   boundedline(x+((s-1)*(fw+offset)),responses(1).mean(:,s),responses(1).sem(:,s));
end
axis off
%set(gca, 'XTick', []);
%set(gca, 'YTick', []);