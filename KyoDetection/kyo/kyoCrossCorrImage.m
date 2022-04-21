function [ccimage]=kyoCrossCorrImage(tc)

ccimage=zeros(size(tc,1),size(tc,2));

tic

thing1 = bsxfun(@minus,tc,mean(tc,3)); 
ad_a   = sum(thing1.*thing1,3);    % Auto corr, for normalization later

for i=1:8
    
    switch i
        case 1
            tc2 = circshift(tc,[1,0,0]);
        case 2
            tc2 = circshift(tc,[0,1,0]);
        case 3
            tc2 = circshift(tc,[-1,0,0]);
        case 4
            tc2 = circshift(tc,[0,-1,0]);
        case 5
            tc2 = circshift(tc,[1,1,0]);
        case 6
            tc2 = circshift(tc,[-1,1,0]);
        case 7
            tc2 = circshift(tc,[1,-1,0]);
        case 8
            tc2 = circshift(tc,[-1,-1,0]);
    end
    
    thing2 = bsxfun(@minus,tc2,mean(tc2,3));
    ad_b   = sum(thing2.*thing2,3);    % Auto corr, for normalization later
    
    % Cross corr
    ccs = sum(thing1.*thing2,3)./sqrt(ad_a.*ad_b); % Cross corr with normalization
    ccimage = ccimage + ccs;       % Get the mean cross corr of the local neighborhood
    
end

ccimage = ccimage./8;

toc  %Elapsed time is...



