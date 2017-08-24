function pnhdl = pnl_modif_drawfill(pr_hdl,pst,glb_fcts,chkbx_function)
dflt_size = [200 240];
unts = get(pr_hdl,'Unit');
rsz_fc = resize_factor(pst,unts,dflt_size);
panel_hdl = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','pnl_draw','Visible','off');
pnhdl.hndl = panel_hdl;
pnhdl.refresh = @refresh;
pnhdl.draw_in_preview = @draw_in_preview;
pnhdl.fill_in_preview = @fill_in_preview;
pnhdl.color_action = @color_action;
chkbx(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','checkbox'...
    ,'Position',[10 220 80 15].*rsz_fc,'String','Zoom'...
    ,'Tag','zoom_points','Callback',{@chkbx_Callback},'Value',0);
chkbx(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','checkbox'...
    ,'Position',[10 195 80 15].*rsz_fc,'String','Draw line'...
    ,'Tag','drawline','Callback',{@chkbx_Callback},'Value',0);
chkbx(3) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','checkbox'...
    ,'Position',[10 170 50 15].*rsz_fc,'String','Fill area'...
    ,'Tag','imfill','Callback',{@chkbx_Callback},'Value',0);
txt_area = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[70 170 100].*rsz_fc(1:3) 15],'Tag','area'...
    ,'String','Filled area: 0 mm2');
chkbx(4) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','checkbox'...
    ,'Position',[10 145 50 15].*rsz_fc,'String','Probe'...
    ,'Tag','probe','Callback',{@chkbx_Callback},'Value',0);
pnhdl.chkbx = chkbx;
str_mod = [];
val_mod = [];
col_drawfill = [1 1 1];
filled_fraction = 0;
filled_area = 0;
pnl_col = uipanel('Parent',panel_hdl,'Unit',unts...
    ,'Position',[10 65 50 70].*rsz_fc,'Tag','pnl_col'...
    ,'Visible','on','BackgroundColor',col_drawfill);
bttn_col = create_color_buttons(panel_hdl,[70 65 120 70].*rsz_fc...
    ,{@bttn_fnct_Callback});
bttn_acc = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[10 10 70 50].*rsz_fc,'Tag','acc','String','Accept'...
    ,'Callback',{@bttn_acc_Callback});
bttn_add = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[120 10 70 50].*rsz_fc,'Tag','addarea','String','Add area'...
    ,'Callback',{@bttn_add_Callback});

    function refresh()
    end
    function varargout = color_action(action,varargin)
        varargout = {};
        if strcmp(action,'get')
            varargout{1} =  col_drawfill;
        elseif strcmp(action,'set')
            col_drawfill = varargin{1};
            %kod ustawiaj¹cy kolor
            set(pnl_col,'BackgroundColor',col_drawfill);
            add_color(bttn_col(1:10),col_drawfill);
        end
    end
    function chkbx_Callback(source,eventdata)
        chkbx_function(source,eventdata);
    end
    function bttn_fnct_Callback(source,eventdata)
        col_drawfill = get(source,'BackgroundColor');
        set(pnl_col,'BackgroundColor',col_drawfill);
        add_color(bttn_col(1:10),col_drawfill);
        glb_fcts.refresh();
    end
    function fill_in_preview(pntr)
        pixpst = pntr(1,2:-1:1);
        str_mod = ['fil:(' num2str(pixpst(1)) ',' num2str(pixpst(1)) ...
            ')col:[' num2str(col_drawfill(1)) ',' num2str(col_drawfill(2)) ','...
            num2str(col_drawfill(3)) ']'];
        val_mod.Pst = pixpst;
        val_mod.col = col_drawfill;
        data = glb_fcts.get_data();
        if~isempty(data)
            pic = glb_fcts.get_act_pict();
            switch data(pic).modifvis(2)
                case 1
                    preview_data = data(pic).picture(1).data;
                case 2
                    md = glb_fcts.get_act_modif();
                    preview_data = data(pic).picture(md).data;
                case 3
                    preview_data = data(pic).picture(end).data;
            end
            [preview_data,filled_fraction]...
                = fill_with_color(preview_data,pixpst,col_drawfill);
            glb_fcts.modification_preview(preview_data);
            if isfield(data(pic),'TotalArea')
                filled_area = data(pic).TotalArea*filled_fraction;
                set(txt_area,'String',['Filled area: ' num2str(filled_area)...
                    ' ' data(pic).Units]);
            end
        end
    end
    function bttn_acc_Callback(source,eventdata)
        data = glb_fcts.get_data();
        pic = glb_fcts.get_act_pict();
        md = glb_fcts.get_act_modif();
        if get(chkbx(2),'Value')
            draw_in_preview();
        end
        if ~isempty(str_mod)&&~isempty(data)
            mdnew = length(data(pic).picture) + 1;
            data(pic).picture(mdnew).data = glb_fcts.get_preview_data();
            data(pic).picture(mdnew).modifstepsstr...
                = [data(pic).picture(md).modifstepsstr {str_mod}];
            data(pic).picture(mdnew).modifstepsval...
                = [data(pic).picture(md).modifstepsval {val_mod}];
            glb_fcts.set_data(data);
            glb_fcts.set_act_modif(mdnew);
            glb_fcts.refresh();
        end
    end
    function draw_in_preview()
        data = glb_fcts.get_data();
        if~isempty(data)
            lineplt = glb_fcts.get_preview_data('drawline');
            if ~isempty(lineplt)
                pic = glb_fcts.get_act_pict();
                switch data(pic).modifvis(2)
                    case 1
                        preview_data = data(pic).picture(1).data;
                    case 2
                        md = glb_fcts.get_act_modif();
                        preview_data = data(pic).picture(md).data;
                    case 3
                        preview_data = data(pic).picture(end).data;
                end
                XData = get(lineplt,'XData');
                YData = get(lineplt,'YData');
                preview_data = draw_on_pict(preview_data,XData,YData...
                    ,col_drawfill);
                glb_fcts.modification_preview(preview_data);
                str_mod = ['drw:col:[' num2str(col_drawfill(1)) ',' ...
                    num2str(col_drawfill(2)) ',' ...
                    num2str(col_drawfill(3)) ']'];
                val_mod.Pst = [XData;YData];
                val_mod.col = col_drawfill;
                delete(lineplt);
            end
        end
    end
    function bttn_add_Callback(source,eventdata)
        data = glb_fcts.get_data();
        if ~isempty(str_mod)&&~isempty(data)
            pic = glb_fcts.get_act_pict();
            if isfield(data(pic),'Units')
                FilledData.samplename = data(pic).samplename;
                FilledData.Area = filled_area;
                FilledData.Units = data(pic).Units;
                FilledData.Type = 'filled_area';
                FilledData.Comment = '';
                prompt = {'Comment for this area:'};
                name = 'Comment input'; 
                numlines = 1;
                defaultanswer = {''};
                options.Resize='on';
                options.WindowStyle='normal';
                options.Interpreter='none';
                glb_fcts.dis_or_enable('disable');
                answer...
                    = inputdlg(prompt,name,numlines,defaultanswer,options);
                glb_fcts.dis_or_enable('enable');
                if ~isempty(answer)
                    FilledData.Comment = answer{1};
                end
                FilledData.Pst = val_mod.Pst;
                FilledData.Str ...
                    = ['Filled area: '...
                    num2str(filled_area) ' ' data(pic).Units ', ' ...
                    data(pic).samplename '/' data(pic).filename];
                AreaData = glb_fcts.areadata('get');
                AreaData = [AreaData FilledData];
                glb_fcts.areadata('set',AreaData);
                glb_fcts.refresh();
            end
        end
    end
end
function color_hdl = create_color_buttons(Parent,Position,bttn_fnct)
    hght = Position(4)/5;
    wdth = Position(3)/6.3;
    for j=1:6
        for i=1:5
            pst = [(Position(1) + wdth*(j-1)) (Position(2) + hght*(i-1))...
                wdth hght];
            if j<3
                color = [0.75 0.75 0.75];
            else
                pst(1) = pst(1)+0.3*wdth;
                color = def_color((j-1)*5+i-10);
            end
            color_hdl((j-1)*5+i) = uicontrol('Parent',Parent...
                ,'Style','pushbutton','String','','BackgroundColor'...
                ,color,'Position',pst,'Tag','color_bttn'...
                ,'Callback',bttn_fnct);%#ok
        end
    end
end
function add_color(bttn_hdl,newcol)
    Nbttn = length(bttn_hdl);
    for i=1:Nbttn
        col = get(bttn_hdl(i),'BackgroundColor');
        if all(col(:)==newcol(:))
            break;
        end
    end
    if i>1
        for j=(i-1):-1:1
            set(bttn_hdl(j+1),'BackgroundColor'...
                ,get(bttn_hdl(j),'BackgroundColor'));
        end
    end
    set(bttn_hdl(1),'BackgroundColor',newcol);
    
end
function color = def_color(nr)
%list of default colors
    col=[1 1 1;...  %white
        0 0 1;...   %blue
        0 1 0;...   %green
        1 0 0;...   %red
        0 0 0;...   %black
        1 0 1;...   %magenta
        0 1 1;...   %cyan
        1 1 0;...   %yellow
        .5 .5 .5;...   %gray
        .5 0 .5; 0 .5 .5; .5 .5 0;...
        .5 0 1; 0 .5 1; .5 1 0;...
        1 0 .5; 0 1 .5; 1 .5 0;...
        .5 1 .5; 1 .5 .5; .5 .5 1;...
        ];
    color=col(1+rem((nr-1),20),:);
end
function image_data = draw_on_pict(image_data,XData,YData,col)
    Size = size(image_data);
	if length(XData)>1
        XL = diff(XData); YL = diff(YData);
        for i=1:length(XL)
            Npix = max(ceil(abs(XL(i))*2),ceil(abs(YL(i))*2));
            if XL(i)~=0
                if Npix>1
                    Xpix = XData(i):(XL(i)/(Npix-1)):XData(i+1);
                else
                    Xpix = mean(XData(i:(i+1)));
                end
            else
                Xpix = XData(i) + zeros(1,Npix);
            end
            if YL(i)~=0
                if Npix>1
                    Ypix = YData(i):(YL(i)/(Npix-1)):YData(i+1);
                else
                    Ypix = mean(YData(i:(i+1)));
                end
            else
                Ypix = YData(i) + zeros(1,Npix);
            end
            Xpix = round(Xpix);
            Ypix = round(Ypix);
            Xpix(Xpix==0) = 1;
            Xpix(Ypix==0) = 1;
            Xpix(Xpix>Size(2)) = Size(2);
            Xpix(Ypix>Size(1)) = Size(1);
            for j=1:Npix
                try
                image_data(Ypix(j),Xpix(j),1)=col(1);
                image_data(Ypix(j),Xpix(j),2)=col(2);
                image_data(Ypix(j),Xpix(j),3)=col(3);
                catch a;
                    disp(a);
                end
            end
        end
	else
        image_data(round(YData),round(XData),1)=col(1);
        image_data(round(YData),round(XData),2)=col(2);
        image_data(round(YData),round(XData),3)=col(3);
	end
end
