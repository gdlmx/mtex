function handles = import_gui_kernel(wzrd)
% page for setting specimen symmetry

pos = get(wzrd,'Position');
h = pos(4);
w = pos(3);
ph = 270;

handles = getappdata(wzrd,'handles');

this_page = get_panel(w,h,ph);
handles.pages = [handles.pages,this_page];
setappdata(this_page,'pagename','Set Smoothing Kernel');

set(this_page,'visible','off');

kg = uibuttongroup('title','Smoothing Kernel',...
  'Parent',this_page,...
  'units','pixels','position',[0 0 w-20 h-120]);

%% ODF approximation

handles.exact = uicontrol(...
  'Parent',kg,...
  'Style','check',...
  'String','use ODF approximation',...
  'Value',1,...
  'position',[10 10 250 20]);

uicontrol(...
  'Parent',kg,...
  'Style','text',...
  'String','Resolution',...
  'HitTest','off',...
  'HorizontalAlignment','left',...
  'position',[300 10 100 15]);

handles.approx = uicontrol(...
  'Parent',kg,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[400 10 40 22],...
  'String','5',...
  'Style','edit');

%% kernel smoothing

uicontrol(...
 'Parent',kg,...
  'String','Kernel',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 40 50 15]);

handles.kernel = uicontrol(...
  'Parent',kg,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Position',[60 40 220 20],...
  'String',blanks(0),...
  'Style','popup',...
  'String',kernel('names'),...
  'Value',1);

uicontrol(...
 'Parent',kg,...
  'String','Halfwidth',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[300 40 90 15]);

handles.halfwidth = uicontrol(...
  'Parent',kg,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[400 40 40 22],...
  'String','5',...
  'Style','edit');

%% kernel plot

handles.kernelAxis = axes(...
  'Parent',kg,...
  'Units','pixels',...
  'Position',[20 90 w-60 h-240],...
  'yTick',[],...
  'box','on');

setappdata(this_page,'goto_callback',@goto_callback);
setappdata(this_page,'leave_callback',@leave_callback);
setappdata(wzrd,'handles',handles);


%% -------------- Callbacks ---------------------------------

function goto_callback(varargin)

handles = getappdata(gcbf,'handles');

if isappdata(gcbf,'kernel')
  k = getappdata(gcbf,'kernel');
else
  k = kernel('de la Vallee Poussin','halfwidth',5*degree);
  setappdata(gcbf,'kernel',k);
end

knames = kernel('names');

set(handles.kernel,'value',find(strcmp(get(k,'name'),knames)));
set(handles.halfwidth,'string',xnum2str(get(k,'hw')/degree));

plotkernel(gcbf);


function leave_callback(varargin)

handles = getappdata(gcbf,'handles');

knames = kernel('names');
kname = get(handles.kernel,'value');

hw = str2double(get(handles.halfwidth,'string'))*degree;

k = kernel(knames{kname},'halfwidth',hw);
setappdata(gcbf,'kernel',k);


%% ------------- Private Functions ------------------------------------------------


function plotkernel(wzrd)

try
  k = getappdata(wzrd,'kernel');
  data = getappdata(wzrd,'data');
  cs = get(data(1),'CS');
  ma = rotangle_max_z(cs);
  omega = linspace(-ma,ma,5000);
  
  handles = getappdata(wzrd,'handles');

  v = eval(k,omega); %#ok<EVLC>
  plot(handles.kernelAxis,omega/degree,v);
  set(handles.kernelAxis,'ylim',[min([0,v]),max(v)],'yTick',[]);
end