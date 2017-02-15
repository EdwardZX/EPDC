function varargout = ParamSetting(varargin)

% Last Modified by GUIDE v2.5 11-Feb-2017 15:32:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ParamSetting_OpeningFcn, ...
                   'gui_OutputFcn',  @ParamSetting_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ParamSetting is made visible.
function ParamSetting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ParamSetting (see VARARGIN)

if varargin{1} > 1
    set(handles.STX_info,'String',strcat(num2str(varargin{1}),32,'Particles are to Process'));
end
handles.index = 0;
handles.param = struct();
handles.param.isValid = zeros(7,1);
handles.param.method = '';
handles.param.timeDelay = 0;
handles.param.dim = 0;
handles.param.k = 0;
handles.param.order = 0;
handles.param.optRepeat = 0;
handles.param.distanceScale = '';

set(handles.EDT_Order,'Enable','off');
set(handles.EDT_timeDelay,'Enable','off');
% Choose default command line output for ParamSetting
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);

% UIWAIT makes ParamSetting wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ParamSetting_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = 0;
    varargout{2} = 0;
    varargout{3} = 0;
    close(gcf);
else
    varargout{1} = handles.output;
    varargout{2} = handles.param;
    varargout{3} = handles.index;
    close(hObject);
end



% --- Executes on button press in BTN_Process.
function BTN_Process_Callback(hObject, eventdata, handles)
% hObject    handle to BTN_Process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.param.distanceScale ~= 'M'
    handles.param.isValid(5) = 1;
end
if handles.param.isValid
	handles.index = 1;
	guidata(hObject,handles);
	uiresume(handles.figure1);
else
	errordlg('ERROR: not all param are set correctly!','MultiPro');		
end




% --- Executes on button press in BTN_Cancel.
function BTN_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to BTN_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.index = 0;
guidata(hObject,handles);
uiresume(handles.figure1);


% --- Executes on button press in RBT_M.
function RBT_M_Callback(hObject, eventdata, handles)
% hObject    handle to RBT_M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
	handles.param.distanceScale = 'M';
	set(handles.RBT_V,'Value',0);
	set(handles.RBT_E,'Value',0);
	set(handles.RBT_C,'Value',0);
    set(handles.EDT_Order,'Enable','on');
	handles.param.isValid(7) = 1;
else
    set(handles.EDT_Order,'Enable','off');
	handles.param.isValid(7) = 0;
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of RBT_M


% --- Executes on button press in RBT_V.
function RBT_V_Callback(hObject, eventdata, handles)
% hObject    handle to RBT_V (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
	handles.param.distanceScale = 'V';
	set(handles.RBT_M,'Value',0);
	set(handles.RBT_E,'Value',0);
	set(handles.RBT_C,'Value',0);
    set(handles.EDT_Order,'Enable','off');
	handles.param.isValid(7) = 1;
else
	handles.param.isValid(7) = 0;
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of RBT_V


% --- Executes on button press in RBT_E.
function RBT_E_Callback(hObject, eventdata, handles)
% hObject    handle to RBT_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
	handles.param.distanceScale = 'E';
	set(handles.RBT_V,'Value',0);
	set(handles.RBT_M,'Value',0);
	set(handles.RBT_C,'Value',0);
    set(handles.EDT_Order,'Enable','off');
	handles.param.isValid(7) = 1;
else
	handles.param.isValid(7) = 0;
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of RBT_E


% --- Executes on button press in RBT_C.
function RBT_C_Callback(hObject, eventdata, handles)
% hObject    handle to RBT_C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
	handles.param.distanceScale = 'C';
	set(handles.RBT_V,'Value',0);
	set(handles.RBT_E,'Value',0);
	set(handles.RBT_M,'Value',0);
    set(handles.EDT_Order,'Enable','off');
	handles.param.isValid(7) = 1;
else
	handles.param.isValid(7) = 0;
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of RBT_C



function EDT_timeDelay_Callback(hObject, eventdata, handles)
% hObject    handle to EDT_timeDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = round(str2num(get(hObject,'String')));
if tmp
	handles.param.timeDelay = tmp;
	handles.param.isValid(2) = 1;
else
	handles.param.isValid(2) = 0;
end
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of EDT_timeDelay as text
%        str2double(get(hObject,'String')) returns contents of EDT_timeDelay as a double


% --- Executes during object creation, after setting all properties.
function EDT_timeDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDT_timeDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDT_Dim_Callback(hObject, eventdata, handles)
% hObject    handle to EDT_Dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = round(str2num(get(hObject,'String')));
if tmp
	handles.param.dim = tmp;
	handles.param.isValid(3) = 1;
else
	handles.param.isValid(3) = 0;
end
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of EDT_Dim as text
%        str2double(get(hObject,'String')) returns contents of EDT_Dim as a double


% --- Executes during object creation, after setting all properties.
function EDT_Dim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDT_Dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDT_K_Callback(hObject, eventdata, handles)
% hObject    handle to EDT_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = round(str2num(get(hObject,'String')));
if tmp
	handles.param.k = tmp;
	handles.param.isValid(4) = 1;
else
	handles.param.isValid(4) = 0;
end
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of EDT_K as text
%        str2double(get(hObject,'String')) returns contents of EDT_K as a double


% --- Executes during object creation, after setting all properties.
function EDT_K_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDT_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDT_Order_Callback(hObject, eventdata, handles)
% hObject    handle to EDT_Order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = round(str2num(get(hObject,'String')));
if tmp
	handles.param.order = tmp;
	handles.param.isValid(5) = 1;
else
	handles.param.isValid(5) = 0;
end
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of EDT_Order as text
%        str2double(get(hObject,'String')) returns contents of EDT_Order as a double


% --- Executes during object creation, after setting all properties.
function EDT_Order_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDT_Order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RBT_Uni.
function RBT_Uni_Callback(hObject, eventdata, handles)
% hObject    handle to RBT_Uni (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
	handles.param.method = 'uni';
	set(handles.RBT_MSD,'Value',0);
	set(handles.RBT_Cor,'Value',0);
	handles.param.isValid(1) = 1;
    set(handles.EDT_timeDelay,'Enable','on');
else
    set(handles.EDT_timeDelay,'Enable','off');
	handles.param.isValid(1) = 0;
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of RBT_Uni


% --- Executes on button press in RBT_MSD.
function RBT_MSD_Callback(hObject, eventdata, handles)
% hObject    handle to RBT_MSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
	handles.param.method = 'msd';
	set(handles.RBT_Uni,'Value',0);
	set(handles.RBT_Cor,'Value',0);
	handles.param.isValid(1) = 1;
    handles.param.timeDelay = 0;
	handles.param.isValid(2) = 1;
    set(handles.EDT_timeDelay,'Enable','off','String','');
else
	handles.param.isValid(1) = 0;
    set(handles.EDT_timeDelay,'Enable','on');
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of RBT_MSD


% --- Executes on button press in RBT_Cor.
function RBT_Cor_Callback(hObject, eventdata, handles)
% hObject    handle to RBT_Cor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
	handles.param.method = 'multi';
	set(handles.RBT_Uni,'Value',0);
	set(handles.RBT_MSD,'Value',0);
	handles.param.isValid(1) = 1;
    set(handles.EDT_timeDelay,'Enable','on');
else
	handles.param.isValid(1) = 0;
    set(handles.EDT_timeDelay,'Enable','off');
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of RBT_Cor



function EDT_OptReapeat_Callback(hObject, eventdata, handles)
% hObject    handle to EDT_OptReapeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = round(str2num(get(hObject,'String')));
if tmp
	handles.param.optRepeat = tmp;
	handles.param.isValid(6) = 1;
else
	handles.param.isValid(6) = 0;
end
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of EDT_OptReapeat as text
%        str2double(get(hObject,'String')) returns contents of EDT_OptReapeat as a double


% --- Executes during object creation, after setting all properties.
function EDT_OptReapeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDT_OptReapeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
