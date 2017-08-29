function [pattern1,pattern2] = adjuststructs(pattern1,pattern2)
%adjusting field of pattern1 and pattern2
    if (isstruct(pattern1)||isempty(pattern1))...
            &&(isstruct(pattern2)||isempty(pattern2))
        if isempty(pattern1) && isempty(pattern2)
            return;
        elseif isempty(pattern2)
            fp1_names = fieldnames(pattern1);
            for i=1:length(fp1_names)
                pattern2.(fp1_names{i}) ...
                    = adjuststructs(pattern1.(fp1_names{i}),[]);
            end
            return;
        elseif isempty(pattern1)
            fp2_names = fieldnames(pattern2);
            for i=1:length(fp2_names)
                pattern1.(fp2_names{i}) ...
                    = adjuststructs(pattern2.(fp2_names{i}),[]);
            end
            return;
        end
        fp1_names = fieldnames(pattern1);
        for j=1:length(pattern2)
            for i=1:length(fp1_names)
                if ~isfield(pattern2,fp1_names{i})
                    pattern2(j).(fp1_names{i}) ...
                        = adjuststructs(pattern1.(fp1_names{i}),[]);
                end
            end
        end
        fp2_names = fieldnames(pattern2);
        for j=1:length(pattern1)
            for i=1:length(fp2_names)
                if ~isfield(pattern1,fp2_names{i})
                    pattern1(j).(fp2_names{i}) ...
                        = adjuststructs(pattern2.(fp2_names{i}),[]);
                end
            end
        end
    end
end