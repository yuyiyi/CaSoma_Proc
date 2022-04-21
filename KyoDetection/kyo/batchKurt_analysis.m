function [movKurt_ori, rois, regions] = batchKurt_analysis(mov, minArea, displayit, SegmentPara)
% Kurtosis Image with mov
datatype = class(mov);
if strcmp(datatype, 'uint8') %#ok<STISA>
    movKurt_ori = uint8(zeros(size(mov, 1), size(mov, 2)));
    for i=1:size(mov, 1)
        for j=1:size(mov, 2)
            movKurt_ori(i,j) = uint8(kurtosis(double(mov(i,j,:))));
        end
    end
    % figure; imagesc(movKurt_ori);

    [rois, regions]=kyoMakeROIsFromCCimage(movKurt_ori,minArea,displayit,SegmentPara); 

else
    movKurt_ori = single(zeros(size(mov, 1), size(mov, 2)));
    for i=1:size(mov, 1)
        for j=1:size(mov, 2)
            movKurt_ori(i,j) = single(kurtosis(double(mov(i,j,:))));
        end
    end
    % figure; imagesc(movKurt_ori);
    [rois, regions]=kyoMakeROIsFromCCimage(movKurt_ori,minArea,displayit,SegmentPara); 
    
end