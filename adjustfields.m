function adjusted = adjustfields(pattern,adjusted)
%adjusting field of adjusted to be coherent with pattern
    if isstruct(pattern)&&(isstruct(adjusted)||isempty(adjusted))
        fp_names = fieldnames(pattern);
        if isempty(adjusted)
            for i=1:length(fp_names)
                adjusted.(fp_names{i}) ...
                    = adjustfields(pattern.(fp_names{i}),[]);
            end
            return;
        end
        for j=1:length(adjusted)
            if isstruct(adjusted)
                for i=1:length(fp_names)
                    if ~isfield(adjusted,fp_names{i})
                        adjusted(j).(fp_names{i}) ...
                            = adjustfields(pattern.(fp_names{i}),[]);
                    end
                end
            end
        end
        fa_names = fieldnames(adjusted);
        if length(fp_names)~=length(fa_names)
            error(['Adjusted structure cannot contain fields extraneous'...
                ' to pattern structure!']);
        end
    end
end