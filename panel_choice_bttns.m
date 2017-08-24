function bttn_hdl = panel_choice_bttns(pr_hdl,pnl_hdl,pst,strcell,varargin)
%function creates buttons to swap between overlapping panels
    unts = get(pr_hdl,'Unit');
    Nb = length(pnl_hdl);%number of buttons
    if length(strcell)<Nb
        for i=(length(strcell)+1):Nb
            strcell(i) = {['P ' num2str(i)]};
        end
    end
    mode = 'horizontal';
    rel_size = ones(1,Nb)/Nb;
%     if ~isempty(varargin)
    for i=1:length(varargin)
        if ischar(varargin{i})
            if strcmp(varargin{1},'vertical')
                mode = 'vertical';
            end
        end
        if isnumeric(varargin{i})&&length(rel_size)==Nb
            rel_size = varargin{i};
            rel_size = rel_size/sum(rel_size);
        end
    end
%     end
    if strcmp(mode,'horizontal')
%         w = pst(3)/Nb;%width of buttons
        w = pst(3)*rel_size;%width of buttons
        h = ones(1,Nb)*pst(4);%height of buttons
%         horpst = (0:(Nb-1))*w + pst(1);%horizontal positions
        horpst = cumsum([0 w(1:(Nb-1))]) + pst(1);%horizontal positions
        verpst = zeros(1,Nb) + pst(2);%vertical positions
    elseif strcmp(mode,'vertical')
        w = ones(1,Nb)*pst(3);%width of buttons
%         h = pst(4)/Nb;%height of buttons
        h = pst(4)*rel_size;%height of buttons
        horpst = zeros(1,Nb) + pst(1);%horizontal positions
%         verpst = ((Nb-1):-1:0)*h + pst(2);%vertical positions
        verpst = cumsum([h((Nb-1):-1:1) 0]) + pst(2);%vertical positions
    end
    bttn_hdl = zeros(1,Nb);
    pnl_tags = cell(1,Nb);
    for i=1:Nb
        pnl_tags(i) = {get(pnl_hdl(i),'Tag')};
        bttn_hdl(i) = uicontrol('Parent',pr_hdl,'Style','pushbutton'...
            ,'Unit',unts,'Position',[horpst(i) verpst(i) w(i) h(i)]...
            ,'String',strcell{i},'Tag',pnl_tags{i}...
            ,'Callback',{@bttn_hdl_Callback});
    end
    function bttn_hdl_Callback(source,eventdata)
        Tag = get(source,'Tag');
        set(pnl_hdl,'Visible','off');
        for it=1:Nb
            if strcmp(Tag,pnl_tags{it})
                set(pnl_hdl(it),'Visible','on');
                break;
            end
        end
    end
end