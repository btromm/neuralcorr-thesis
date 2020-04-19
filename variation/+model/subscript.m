function [str] = subscript(channel)
    channel_length = length(channel);
    str = '_';
    idx = 1;
    while(idx <= channel_length)
        if(str(end) == '_')
            str = append(str,channel(idx));
            idx = idx+1;
        else
            str = append(str,'_');
        end
    end
end

