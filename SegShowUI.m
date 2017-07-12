function varargout = SegShowUI(varargin)
% SEGSHOWUI MATLAB code for SegShowUI.fig
%      SEGSHOWUI, by itself, creates a new SEGSHOWUI or raises the existing
%      singleton*.
%
%      H = SEGSHOWUI returns the handle to a new SEGSHOWUI or the handle to
%      the existing singleton*.
%
%      SEGSHOWUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGSHOWUI.M with the given input arguments.
%
%      SEGSHOWUI('Property','Value',...) creates a new SEGSHOWUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SegShowUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SegShowUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SegShowUI

% Last Modified by GUIDE v2.5 07-Jul-2017 15:02:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SegShowUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SegShowUI_OutputFcn, ...
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


% --- Executes just before SegShowUI is made visible.
function SegShowUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SegShowUI (see VARARGIN)

% Choose default command line output for SegShowUI
handles.output = hObject;
handles.model = varargin{1};
linkaxes([handles.axes_main,handles.axes_seg,...
          handles.axes_main_2,handles.axes_seg_2],'x');
handles.model.setFigHandles(handles);
handles.model.onMainDraw();
handles.model.onSegDraw();
handles.model.onSwitchMain(1);
handles.btn_active.Enable = 'off';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SegShowUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SegShowUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edt_segFrom_Callback(hObject, eventdata, handles)
% hObject    handle to edt_segFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject,'String');
try
    num = str2double(str);
catch
    errordlg(sprintf('Failed Parse Input: %s',str));
end
handles.model.onSegFrom(num);
% Hints: get(hObject,'String') returns contents of edt_segFrom as text
%        str2double(get(hObject,'String')) returns contents of edt_segFrom as a double

% --- Executes during object creation, after setting all properties.
function edt_segFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_segFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edt_segTo_Callback(hObject, eventdata, handles)
% hObject    handle to edt_segTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject,'String');
try
    num = str2double(str);
catch
    errordlg(sprintf('Failed Parse Input: %s',str));
end
handles.model.onSegTo(num);
% Hints: get(hObject,'String') returns contents of edt_segTo as text
%        str2double(get(hObject,'String')) returns contents of edt_segTo as a double

% --- Executes during object creation, after setting all properties.
function edt_segTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_segTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edt_yrange_Callback(hObject, eventdata, handles)
% hObject    handle to edt_yrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject,'String');
if isempty(strfind(str,' '))
    errordlg('Failed Parse Input: %s',str);
else
    str = strsplit(str,' ');
    try
        handles.model.onYRange(str2double(str{1}),str2double(str{2}));
    catch
        errordlg('Failed Parse Input: %s',str);
    end
end
% Hints: get(hObject,'String') returns contents of edt_yrange as text
%        str2double(get(hObject,'String')) returns contents of edt_yrange as a double

% --- Executes during object creation, after setting all properties.
function edt_yrange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_yrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edt_xrange_Callback(hObject, eventdata, handles)
% hObject    handle to edt_xrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject,'String');
if isempty(strfind(str,' '))
    errordlg(sprintf('Failed Parse Input: %s',str));
else
    strs = strsplit(str,' ');
    try
        handles.model.onXRange(str2double(strs{1}),str2double(strs{2}));
    catch
        errordlg(sprintf('Failed Parse Input: %s',str));
    end
end
% Hints: get(hObject,'String') returns contents of edt_xrange as text
%        str2double(get(hObject,'String')) returns contents of edt_xrange as a double

% --- Executes during object creation, after setting all properties.
function edt_xrange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_xrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_copy.
function btn_copy_Callback(hObject, eventdata, handles)
% hObject    handle to btn_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onCopyFig();

% --- Executes during object creation, after setting all properties.
function btn_copy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btn_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in btn_hold.
function btn_hold_Callback(hObject, eventdata, handles)
% hObject    handle to btn_hold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onHoldRange();


% --- Executes on button press in btn_curFigIndicator_1.
function btn_curFigIndicator_1_Callback(hObject, eventdata, handles)
% hObject    handle to btn_curFigIndicator_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onSwitchMain(1);

% --- Executes on button press in btn_curFigIndicator_2.
function btn_curFigIndicator_2_Callback(hObject, eventdata, handles)
% hObject    handle to btn_curFigIndicator_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onSwitchMain(2);


% --- Executes on button press in btn_fromLast.
function btn_fromLast_Callback(hObject, eventdata, handles)
% hObject    handle to btn_fromLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onSegFrom(handles.model.selectFrom-1);


% --- Executes on button press in btn_fromNext.
function btn_fromNext_Callback(hObject, eventdata, handles)
% hObject    handle to btn_fromNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onSegFrom(handles.model.selectFrom+1);

% --- Executes on button press in btn_toLast.
function btn_toLast_Callback(hObject, eventdata, handles)
% hObject    handle to btn_toLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onSegTo(handles.model.selectTo-1);

% --- Executes on button press in btn_toNext.
function btn_toNext_Callback(hObject, eventdata, handles)
% hObject    handle to btn_toNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onSegTo(handles.model.selectTo+1);


% --- Executes on selection change in pop_xData.
function pop_xData_Callback(hObject, eventdata, handles)
% hObject    handle to pop_xData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onXDataType(get(hObject,'Value'));
% Hints: contents = cellstr(get(hObject,'String')) returns pop_xData contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_xData


% --- Executes during object creation, after setting all properties.
function pop_xData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_xData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_yData.
function pop_yData_Callback(hObject, eventdata, handles)
% hObject    handle to pop_yData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onYDataType(get(hObject,'Value'));
% Hints: contents = cellstr(get(hObject,'String')) returns pop_yData contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_yData


% --- Executes during object creation, after setting all properties.
function pop_yData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_yData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_plotType.
function pop_plotType_Callback(hObject, eventdata, handles)
% hObject    handle to pop_plotType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v = get(hObject,'Value');
% if v == 3
%     tmpP = handles.axes_plot.Position;
%     delete(handles.axes_plot);
%     handles.axes_plot = polaraxes('Parent',handles.figure1,'Position',tmpP);
%     guidata(hObject,handles);
% end
handles.model.onPlotTypeSelected(v);
% Hints: contents = cellstr(get(hObject,'String')) returns pop_plotType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_plotType


% --- Executes during object creation, after setting all properties.
function pop_plotType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_plotType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_holdTrace.
function btn_holdTrace_Callback(hObject, eventdata, handles)
% hObject    handle to btn_holdTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onHoldTrace();


% --- Executes on button press in btn_active.
function btn_active_Callback(hObject, eventdata, handles)
% hObject    handle to btn_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.model.onActivePlot();
