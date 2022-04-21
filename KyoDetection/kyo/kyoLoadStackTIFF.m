function [imstack1,imstack2] = kyoLoadStackTIFF(fn,deinterleveFlag)

if nargin<2
    deinterleveFlag=0;
end

FileTif=fn;
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
imstack=zeros(nImage,mImage,NumberImages,'uint16');

TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   imstack(:,:,i)=TifLink.read();
end
TifLink.close();

if deinterleveFlag
    %imstack1=zeros(nImage,mImage,NumberImages,'uint16');
    %imstack2=zeros(nImage,mImage,NumberImages,'uint16');
    imstack1=imstack(:,:,1:2:NumberImages-1);
    imstack2=imstack(:,:,2:2:NumberImages);
else
    imstack1=imstack;
    imstack2=[];
end


