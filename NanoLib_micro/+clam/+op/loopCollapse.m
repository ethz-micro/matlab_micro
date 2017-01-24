function file = loopCollapse(file)
% collapse all loops to one

for i = 1:numel(file.channels)
    data = file.channels(i).data;
    data = sum(data,2)/size(data,2);

    file.channels(i).data = data;
end

file.header.loops = 1;

