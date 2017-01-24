function newFile = combineFiles(files,channels)

narginchk(1,2)
if ~exist('channels','var')
    channels = 1:numel(files(1).channels);
end

nFiles = numel(files);

newFile.header = files(1).header;
for i = 1:nFiles
    for j = 1:numel(channels)
        jChn = channels(j);
        if i == 1            
            newFile.channels(jChn).data = files(i).channels(jChn).data./nFiles;
            newFile.channels(jChn).Direction = files(i).channels(jChn).Direction;
            newFile.channels(jChn).Name = files(i).channels(jChn).Name;
            newFile.channels(jChn).Unit = files(i).channels(jChn).Unit;
        else
            if ~strcmp(newFile.channels(jChn).Direction,files(i).channels(jChn).Direction) || ...
                 ~strcmp(newFile.channels(jChn).Name,files(i).channels(jChn).Name) || ...
                 ~strcmp(newFile.channels(jChn).Unit,files(i).channels(jChn).Unit)
            error('file mismatch');
            end
            newFile.channels(jChn).data = [newFile.channels(jChn).data, files(i).channels(jChn).data./nFiles];
        end
        
    end
    
end
    
for j = 1:numel(channels)
    jChn = channels(j);
    newFile.channels(jChn).data = sum(newFile.channels(jChn).data,2);
end


% combine channels
%     %Get data
%     data = cat(3,file.channels(chn).data);
%     weights(1,1,:)=chw(:);
%     data = data .* repmat(weights,size(data,1),size(data,2),1);
%     channel.data = squeeze (sum(data,3));
