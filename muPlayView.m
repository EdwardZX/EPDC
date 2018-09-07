function varargout = muPlayView(varargin)
% MUPLAYVIEW MATLAB code for muPlayView.fig
%      MUPLAYVIEW, by itself, creates a new MUPLAYVIEW or raises the existing
%      singleton*.
%
%      H = MUPLAYVIEW returns the handle to a new MUPLAYVIEW or the handle to
%      the existing singleton*.
%
%      MUPLAYVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MUPLAYVIEW.M with the given input arguments.
%
%      MUPLAYVIEW('Property','Value',...) creates a new MUPLAYVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before muPlayView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to muPlayView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help muPlayView

% Last Modified by GUIDE v2.5 19-Mar-2018 13:55:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @muPlayView_OpeningFcn, ...
                   'gui_OutputFcn',  @muPlayView_OutputFcn, ...
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


% --- Executes just before muPlayView is made visible.
function muPlayView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to muPlayView (see VARARGIN)

% Choose default command line output for muPlayView
handles.output = handles;
handles.hModel = varargin{1};
handles.hModel.pResult.plotTest(handles.axes1,handles.hModel.pResult.rawData);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes muPlayView wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = muPlayView_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_play.
function btn_play_Callback(hObject, eventdata, handles)
% hObject    handle to btn_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.onPlay();
