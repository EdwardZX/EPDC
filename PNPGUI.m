classdef PNPGUI < handle
    properties      
        currentPointIndex;
        hFullTrace;
        hLocalTrace;
        hData;
        hVelocity;
        hFigure;
    end

    properties (Access = private)
        pT;
        hClickButton;
        hNextButton;
        hLastButton;
        hEditBox;
        hJampToButton;
        hKeepRangeButton;
        h3DViewButton;
        hIsFilterCB;
        hGroupListBox;
  
        viewSize;
        isKeepRange;
        
        isShowGroup;
        
        colors;
        is3DView;
    end

    methods (Access = public)
        function obj = PNPGUI(pT)
            obj.pT = pT;
            obj.currentPointIndex = pT.header;
            obj.isKeepRange = 0;
            obj.isShowGroup = zeros(obj.pT.k,1);
            obj.colors = lines(7);
            obj.is3DView = false;
        end

        function show(obj)
            obj.viewSize = get(0,'ScreenSize');
            obj.viewSize(4) = obj.viewSize(3)/2.3;
            obj.hFigure = figure('pos',obj.viewSize); 
            obj.update();
            obj.hClickButton = uicontrol('parent',obj.hFigure,'string','select','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49,80,49]);
            set(obj.hClickButton,'callback',@obj.onSelect);
            obj.hNextButton = uicontrol('parent',obj.hFigure,'string','Next','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*2,80,49]);
            set(obj.hNextButton,'callback',@obj.onNext);
            obj.hLastButton = uicontrol('parent',obj.hFigure,'string','Last','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*3,80,49]);
            set(obj.hLastButton,'callback',@obj.onLast);
            obj.hEditBox = uicontrol('parent',obj.hFigure,'style','edit','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*4,80,49]);
            obj.hJampToButton = uicontrol('parent',obj.hFigure,'string','JumpTo','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*5,80,49]);
            set(obj.hJampToButton,'callback',@obj.onEnter);
            obj.hJampToButton = uicontrol('parent',obj.hFigure,'string','JumpTo','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*5,80,49]);
            set(obj.hJampToButton,'callback',@obj.onEnter);
            obj.hKeepRangeButton = uicontrol('parent',obj.hFigure,'string','Keep Range','Style','radiobutton','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*6,80,25]);
            set(obj.hKeepRangeButton,'callback',@obj.onKeepRange);
            obj.hIsFilterCB = uicontrol('parent',obj.hFigure,'string','Filter Group','Style','checkbox','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*6.5,80,25],'Value',0);
            set(obj.hIsFilterCB,'callback',@obj.onFilterGroup);            
            obj.hGroupListBox = uicontrol('parent',obj.hFigure,'string',num2str((1:1:obj.pT.k)'),'Style','listbox','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*9.5,80,130],'Enable','off');
            set(obj.hGroupListBox,'callback',@obj.onGroupClick);        
            obj.h3DViewButton = uicontrol('parent',obj.hFigure,'string','Go 3D View','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*11,80,49]);
            set(obj.h3DViewButton,'callback',@obj.on3DViewClick);
        end
        
        function r = getR(obj)
            r = obj.pT;
        end
        
        function saveMovie(obj,varargin)
            if nargin == 1
                indexFrom = obj.pT.header; indexTo = obj.pT.realIndex(end);
            elseif nargin == 2
                indexFrom = varargin{1}; indexTo = obj.pT.realIndex(end);
            else
                indexFrom = varargin{1}; indexTo = varargin{2};
            end
            %obj.show();
            v = EasyVideoWriter(obj.hFigure);
            for m = indexFrom:indexTo
                if obj.changePoint(m)
                    v.ticVideo();
                else
                    v.endVideo();
                end
            end
            v.endVideo();
        end
    end

    methods (Access = private)
        function h = plotFullTrace(obj)
            if obj.isKeepRange
                tmpX = xlim();
                tmpY = ylim();
            end
            if obj.is3DView
                tmpZ = zlim();
                [az,el] = view();
                h = plot3(obj.pT.xy(:,1),obj.pT.xy(:,2),1:1:size(obj.pT.xy,1),'DisplayName','Particle Motion Trace','Color',obj.colors(1,:));
                PNPGUI.scatterGroupTo3(obj.pT.indexTag,obj.pT.k,obj.pT.xy(obj.pT.realIndex,:),obj.isShowGroup,obj.colors(2:7,:),obj.pT.header - 1);
                scatter3(obj.pT.xy(obj.currentPointIndex,1),...
                         obj.pT.xy(obj.currentPointIndex,2),...
                         obj.currentPointIndex,...
                         30,'k','filled','DisplayName','Current Point');  
                box on;
                grid on;
                hold off; 
            else
                h = plot(obj.pT.xy(:,1),obj.pT.xy(:,2),'DisplayName','Particle Motion Trace','Color',obj.colors(1,:));
                PNPGUI.scatterGroupTo(obj.pT.indexTag,obj.pT.k,obj.pT.xy(obj.pT.realIndex,:),obj.isShowGroup,obj.colors(2:7,:));
                scatter(obj.pT.xy(obj.currentPointIndex,1),...
                        obj.pT.xy(obj.currentPointIndex,2),...
                        30,'k','filled','DisplayName','Current Point');  
                hold off; 
            end             
            if obj.isKeepRange
                xlim(tmpX);
                ylim(tmpY);
                if obj.is3DView
                    zlim(tmpZ);
                    view(az,el);
                end
            end
        end

        function h = plotLocalTrace(obj)
            if obj.pT.header <= 10
                header = 10;
            else
                header = obj.pT.header;
            end
            realRange = obj.currentPointIndex - header + (1:1:header);
            
            if any(realRange < 0)
                realRange = realRange - min(realRange) + 1;
            end

            relativeRange = realRange - header + 1;
            relativeRange = relativeRange(relativeRange > 0);

            localXY = obj.pT.xy(realRange,:);
            h = plot(localXY(:,1),localXY(:,2),'DisplayName','Local Trace','Color',obj.colors(1,:));
            xlim([min(localXY(:,1)),max(localXY(:,1))]);
            ylim([min(localXY(:,2)),max(localXY(:,2))]);

            PNPGUI.scatterGroupTo(obj.pT.indexTag(relativeRange),obj.pT.k,...
                                  obj.pT.xy(realRange(realRange >= header),:),...
                                  obj.isShowGroup,obj.colors(2:7,:));

            scatter(obj.pT.xy(obj.currentPointIndex,1),...
                    obj.pT.xy(obj.currentPointIndex,2),...
                    30,'k','filled','DisplayName','Current Point');  
            hold off;
        end

        function h = plotData(obj)         
            h = plot(obj.pT.getResultAt(obj.currentPointIndex - obj.pT.header + 1),'-','DisplayName',obj.pT.analysisMethod,'LineWidth',3);
            hold on;
            for m = 1:1:size(obj.pT.centric,1)
                plot(obj.pT.centric(m,:),'--','DisplayName',strcat('Group:',32,num2str(m)));
            end
            xlim([0,size(obj.pT.centric,2)]);
            hold off;
        end

        function h = plotVelocity(obj)
            if obj.isKeepRange
                tmpX = xlim();
            end
            h = plot(obj.pT.velocity,'DisplayName','Velocity','Color',obj.colors(1,:));
            Ptrace = [obj.pT.realIndex',obj.pT.velocity(obj.pT.realIndex)];
            PNPGUI.scatterGroupTo(obj.pT.indexTag,obj.pT.k,Ptrace,obj.isShowGroup,obj.colors(2:7,:));
            scatter(obj.currentPointIndex,...
                    obj.pT.velocity(obj.currentPointIndex),...
                    30,'k','filled','DisplayName','CurrentPoint');
            hold off;
            if obj.isKeepRange
                xlim(tmpX);
            end
        end

        function res = changePoint(obj,index)
            isValid = and(index >= obj.pT.header,index < obj.pT.realIndex(end));
            if isValid
                obj.currentPointIndex = index;
                obj.update();
                res = 1;
            else
                errordlg('Error: Invalid Point!','NP Analysis Container');
                res = 0;
            end
        end

        function update(obj)
            subplot(2,4,[1,2,5,6]);
            obj.hFullTrace = obj.plotFullTrace();
            subplot(2,4,3);
            obj.hLocalTrace = obj.plotLocalTrace();
            subplot(2,4,4);
            obj.hData = obj.plotData();
            subplot(2,4,[7,8]);
            obj.hVelocity = obj.plotVelocity();  
            title(strcat('Select Point: ',num2str(obj.currentPointIndex)));
        end

        function onSelect(obj,varargin)
            [x,~] = ginput(1);
            obj.changePoint(round(x));  
        end
        
        function onNext(obj,varargin)
            obj.changePoint(obj.currentPointIndex + 1);
        end
        
        function onLast(obj,varargin)
            obj.changePoint(obj.currentPointIndex - 1);
        end
        function onEnter(obj,varargin)
            obj.changePoint(round(str2double(get(obj.hEditBox,'string'))));
        end
        function onKeepRange(obj,varargin)
            obj.isKeepRange = get(obj.hKeepRangeButton,'Value');
        end
        function onFilterGroup(obj,varargin)
            if varargin{1}.Value
                set(obj.hGroupListBox,'Enable','on');
            else
                set(obj.hGroupListBox,'Enable','off');
                obj.isShowGroup = zeros(obj.pT.k,1);
                obj.update();
            end
        end
        
        function onGroupClick(obj,varargin)
            obj.isShowGroup = logical(obj.isShowGroup + 1);
            obj.isShowGroup(varargin{1}.Value) = 0;
            obj.update();
        end
        
        function on3DViewClick(obj,varargin)
            if obj.is3DView
                obj.is3DView = false;
                set(obj.h3DViewButton,'string','Go 3D View');
            else
                if obj.isKeepRange
                    warndlg('Please unable KeepRange Button first!');
                    return;
                end
                obj.is3DView = true;
                set(obj.h3DViewButton,'string','Go 2D View');
            end
            obj.update();
        end
    end

    methods (Static)
        function [] = scatterGroupTo(Tag,k,trace,isShow,colors)
            L = size(colors,1);
            hold on;
            for m = 1:1:k
                if(~isShow(m))
                    if mod(m,L)
                        scatter(trace(Tag==m,1),trace(Tag == m,2),10,'filled','DisplayName',strcat('Grounp: ',num2str(m)),'MarkerFaceColor',colors(mod(m,L),:));  
                    else
                        scatter(trace(Tag==m,1),trace(Tag == m,2),10,'filled','DisplayName',strcat('Grounp: ',num2str(m)),'MarkerFaceColor',colors(L,:));  
                    end
                end
            end
        end
        function [] = scatterGroupTo3(Tag,k,trace,isShow,colors,offset)
            L = size(colors,1);
            timeIndices = (1:1:size(trace,1)) + offset;
            hold on;
            for m = 1:1:k
                if(~isShow(m))
                    subIndex = (Tag == m);                   
                    if mod(m,L)
                        scatter3(trace(subIndex,1),trace(subIndex,2),timeIndices(subIndex),10,...
                            'filled','DisplayName',strcat('Grounp: ',num2str(m)),'MarkerFaceColor',colors(mod(m,L),:));  
                    else
                        scatter3(trace(subIndex,1),trace(subIndex,2),timeIndices(subIndex),10,...
                            'filled','DisplayName',strcat('Grounp: ',num2str(m)),'MarkerFaceColor',colors(L,:));  
                    end
                end
            end
        end
    end
end