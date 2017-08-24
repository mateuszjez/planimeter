function bttn_hdl = updown_btts(pr_hdl,ix_hdl,get_entries,set_entries,pst,varargin)
%UPDOWN_BTTS - Function updown_btts creates buttons to manage data in displayed in
%           listboxes and similar UI controls like popupmenu. It provides 5 buttons
%           for moving data entries or their removing.
%
%bttn_hdl = updown_btts(Parent,UIHandle,get_entries_Fnct,set_entries_Fnct,Position,...)
%   bttn_hdl            - handles of created buttons
%   Parent              - parent panel or figure handle
%   UIHandle            - handle of control for displaying entries
%   get_entries_Fnct    - handle of function for picking up the entry data
%   set_entries_Fnct    - handle of function for setting up the rearranged data
%   Position            - position of the set of buttons
%   updown_btts(pr_hdl,lstbx_hdl,@()entries,@set_entries,[0 0 100 20])
%
%Additional parameters:
%
%To choose particular buttons:
%	1:Up 
%   2:Down 
%   3:Remove 
%   4:To top 
%   5:To bottom
%   updown_btts(...,[0 0 100 20],1:3);
%
%To pass refresh function handle:
%   updown_btts(...,[0 0 100 20],1:3,@refreshFnct);
%
%To manage buttons vertically or horizontally(default):
%   updown_btts(...,[0 0 100 20],'ver');
%
%Additional can be also passed through structure:
%   prop.ChosenButtons     = 1:3;
%   prop.RelativeSizes     = [40 40 30];
%   prop.RelativeSpacing   = [0 5];         -  spacing between buttons
%   prop.Direction         = 'vertical';
%   prop.RefreshFuncHandle = @refreshFnct;  -  must not accept input data
%   updown_btts(...,[0 0 100 20],prop);

    str = [{'Up'} {'Down'} {'Remove'} {'To top'} {'To bottom'}];
    Tags = [{'up'} {'dwn'} {'rmv'} {'top'} {'bot'}];
    unts = get(pr_hdl,'Unit');
    
    %default values and functions that can to be assigned by the user
    refresh         = @()[]; %dumb function as deafault
    Direction       = 'horizontal';
    ChosenButtons   = 1:5;
    rel_sizes       = [60 60 40 60 60];%relative sizes
    Spacing         = [0 5 5 5];
    
    %user variable and refresh function assignments
    if ~isempty(varargin)
        for iv = 1:length(varargin)
            if isnumeric(varargin{iv})
                ChosenButtons   = varargin{iv};
            end
            if isa(varargin{iv},'function_handle')
                refresh         = varargin{iv};
            end
            if ischar(varargin{iv})
                Direction       = varargin{iv};
            end
            if isstruct(varargin{iv})
                prop            = varargin{iv};
                fnames          = fieldnames(prop);
                for i=1:length(fnames)
                    if strcmp(fnames{i},'ChosenButtons')
                        ChosenButtons   = prop.ChosenButtons;
                    elseif strcmp(fnames{i},'RelativeSizes')
                        rel_sizes       = prop.RelativeSizes;
                    elseif strcmp(fnames{i},'RelativeSpacing')
                        Spacing         = prop.RelativeSpacing;
                    elseif strcmp(fnames{i},'Direction')
                        Direction       = prop.Direction;
                    elseif strcmp(fnames{i},'RefreshFuncHandle')
                        refresh         = prop.RefreshFuncHandle;
                    end
                end
            end
        end
    end
    Spacing = Spacing(1:(length(ChosenButtons)-1));
%     bwidth      - button width
%     bheight     - button height
%     bwpos       - button horizontal position
%     bhpos       - button vertical position
%     sumbheight  - sum of button heights and spacings (only for vertical
%                   alignment)
    if strcmp(Direction(1:3),'hor')%horizontal
        bwidth      = rel_sizes(1:length(ChosenButtons));
        bheight     = ones(1,length(bwidth))*30;
        bwpos       = [0 cumsum(bwidth(1:(end-1)) + Spacing)];
        bhpos       = zeros(length(bwpos),1);
    elseif strcmp(Direction(1:3),'ver')%vertical
        bheight     = rel_sizes(1:length(ChosenButtons));
        bwidth      = ones(1,length(bheight))*30;
        sumbheight  = sum(bheight) + sum(Spacing);
        bhpos       = zeros(length(bheight),1);
        bhpos(1)    = sumbheight - bheight(1);
        if length(bheight)>1
            bhpos(2:end) = bhpos(1) - cumsum(bheight(2:end) + Spacing);
        end
        bwpos = zeros(length(bhpos),1);
    end
%     dflt_size   - default overall width and height
%     str         - captions of chosen buttons
%     bttnpst     - position and sizes of particular buttons
%     bttn_hdl    - array to store handles of chosen buttons
    dflt_size   = [(bwpos(end)+bwidth(end)) (bhpos(1)+bheight(1))];
    str         = str(ChosenButtons);
    Tags        = Tags(ChosenButtons);
    bttnpst     = zeros(length(bwidth),4);
    bttn_hdl    = zeros(length(bwidth),1);
    rsz_fc      = resize_factor(pst,unts,dflt_size);
    for i=1:length(bwidth)
        bttnpst(i,:) = [bwpos(i) bhpos(i) bwidth(i) bheight(i)].*rsz_fc...
             + [pst(1) pst(2) 0 0];
        bttn_hdl(i)  = uicontrol('Parent',pr_hdl,'Style','pushbutton'...
            ,'Unit',unts,'Position',bttnpst(i,:),'String',str{i}...
            ,'Tag',Tags{i},'Callback',{@updown_btts_Callback});
    end
    function updown_btts_Callback(source,eventdata)
        Tag     = get(source,'Tag');
        entries = get_entries();
        if ishandle(ix_hdl)
            ix      = get(ix_hdl,'Value');
            if length(ix)>1; 
                ix  = ix(1,1);
            end
        elseif iscell(ix_hdl)
            getix   = ix_hdl{1};
            ix      = getix();
        else
            ix      = ix_hdl();
        end
        if strcmp(Tag,'up') && length(entries)>1
            if ix>1
                entries((ix-1):ix) = entries(ix:-1:(ix-1));
                ix  = ix - 1;
            end
        elseif strcmp(Tag,'dwn') && length(entries)>1
            if ix<length(entries)
                entries(ix:(ix+1)) = entries((ix+1):-1:ix);
                ix  = ix + 1;
            end
        elseif strcmp(Tag,'rmv') && length(entries)>1
            if ix==1
                entries = entries(2:end);
            elseif ix==length(entries)
                entries = entries(1:(end-1));
                ix      = ix - 1;
            else
                entries = [entries(1:(ix-1)) entries((ix+1):end)];
            end
        elseif strcmp(Tag,'top') && length(entries)>1
            if ix==length(entries)
                entries = [entries(end) entries(1:(end-1))];
            elseif ix>1
                entries = [entries(ix) ...
                    entries(1:(ix-1)) entries((ix+1):end)];
            end
        elseif strcmp(Tag,'bot') && length(entries)>1
            if ix==1
                entries = [entries(2:end) entries(1)];
            elseif ix<length(entries)
                entries = [entries(1:(ix-1)) entries((ix+1):end) ...
                    entries(ix)];
            end
        end
        set_entries(entries);
        if ishandle(ix_hdl)
            set(ix_hdl,'Value',ix);
        elseif iscell(ix_hdl)
            setix = ix_hdl{2};
            setix(ix);
        end
        refresh();
    end
end
