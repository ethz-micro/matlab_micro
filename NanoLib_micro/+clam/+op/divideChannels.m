function chn3 = divideChannels(chn1,chn2)
% collapse all loops to one

if size(chn1.data)==size(chn2.data)
    if strcmp(chn1.Direction,chn2.Direction)
        chn3.Direction = chn1.Direction;
        chn3.Name = sprintf('%s/%s',chn1.Name,chn2.Name);
        if strcmp(chn1.Unit,chn2.Unit)
            chn3.Unit = 'a.u.';
        else
            chn3.Unit = sprintf('%s/%s',chn1.Unit,chn2.Unit);
        end
        
        chn3.data = chn1.data/chn2.data;
    else
        error('try to combine two different directions');
    end
    
else
    error('size between channel 1 and channel 2 mismatch');
    
end

