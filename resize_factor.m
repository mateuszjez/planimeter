function rsz_fc = resize_factor(pst,unts,deaf_size)
    if strcmp(unts,'pixels')
        if length(pst)==2
            rsz_fc = 1;%resize (scaling) factor
        elseif length(pst)==4
            rsz_fc = pst(3:4)./deaf_size;
        else
            error('Length of the pst argument must be 2 or 4.');
        end
    elseif strcmp(unts,'normalized')
        error('Normalized units not suported yet.');
    else
        error('Not suported units.');
    end
    rsz_fc = [rsz_fc rsz_fc];
end