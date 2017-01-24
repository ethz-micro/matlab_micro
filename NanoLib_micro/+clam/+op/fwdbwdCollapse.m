function [newFile,deltaX] = fwdbwdCollapse(file,chn)


if numel(chn) ~= 2
    error('provide 2 channels')
end

%% calculate data by mean of cross correlation
s1 = file.channels(chn(1)).data(:,1);
s2 = file.channels(chn(2)).data(:,1);
%
[acor,lag] = xcorr(s2,s1);
[~,I] = max(abs(acor));
lagDiff = lag(I);

% sum data of all channels
newFile.header = file.header;

% energy
newFile.channels(1).Name = file.channels(1).Name;
newFile.channels(1).Unit = file.channels(1).Unit;
newFile.channels(1).Direction = 'Both';
newFile.channels(1).data = file.channels(1).data(:,1);
% other channels
k = 2;
x = newFile.channels(1).data;
for i = 2:2:numel(file.channels)
    %
    %info
    newFile.channels(k).Name = file.channels(i).Name;
    newFile.channels(k).Unit = file.channels(i+1).Unit;
    newFile.channels(k).Direction = 'Both';
    %data
    s1 = file.channels(i).data(:,1);
    s2 = file.channels(i+1).data(:,1);
    s3 = s1;
    %{ 
    % version 1
    if lagDiff >= 0
        s3(1:end-lagDiff) = s1(1:end-lagDiff)+s2(1+lagDiff:end);
        deltaX = -(x(1)-x(abs(lagDiff)));
    else
        s3(1-lagDiff:end) = s1(1-lagDiff:end)+s2(1:end+lagDiff);
        deltaX = x(1)-x(abs(lagDiff));
    end
    newFile.channels(k).data = s3/2;
    %}
    
        % version 1
    if lagDiff >= 0
        s3(1:end-lagDiff) = (s1(1:end-lagDiff)+s2(1+lagDiff:end))/2;
        deltaX = -(x(1)-x(abs(lagDiff)));
    else
        s3(1-lagDiff:end) = (s1(1-lagDiff:end)+s2(1:end+lagDiff))/2;
        deltaX = x(1)-x(abs(lagDiff));
    end
    newFile.channels(k).data = s3;
    k = k+1;
    % plot  check
    %{
    figure
    plot(x,s1,'DisplayName','fwd'); hold on
    plot(x+deltaX,s2,'DisplayName','dwd');
    plot(x,s3);
    %}
end





