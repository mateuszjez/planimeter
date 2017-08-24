function show_sequence(sequence_data)
ScrSiz = get(0,'ScreenSize');
figpst = [0.7*ScrSiz(3) 0.4*ScrSiz(4) 0.13*ScrSiz(3) 0.3*ScrSiz(4)];
fighndl = figure('Position',figpst,'MenuBar','none');
uicontrol('Parent',fighndl,'Style','listbox','Units','normalized'...
    ,'Position',[0.02,0.2,0.96,0.78],'String',sequence_data.modifstepsstr);
uicontrol('Parent',fighndl,'Style','pushbutton','Units','normalized'...
    ,'Position',[0.15,0.02,0.7,0.16],'String','OK'...
    ,'Callback',{@(source,eventdata)delete(fighndl)});
end