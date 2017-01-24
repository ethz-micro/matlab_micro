function [ePeak,iPeak] = getMax(xd,yd,xRange)

nargin(3,3)

dataSG = utility.doSgolay(xd',yd',3,11)';
yP = dataSG;

yP(xd<xRange(1),:) = 0;
yP(xd>xRange(2),:) = 0;

[ePeak,iPeak] = max(yP);

end