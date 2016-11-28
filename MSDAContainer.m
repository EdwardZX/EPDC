classdef MSDAContainer < handle
    properties 
        currentPointIndex;
        name;
        hFullTrace;
        hLocalTrace;
        hMSD;
        hVelocity;
        hFigure;
        hClickButton;
        hNextButton;
        hLastButton;
        hEditBox;
        hEnterButton;
        viewSize;
    end
    properties (Access = private)
        param;
        trajectory;
        result;
        velocity;
        colorMap;
    end

    events
        onPointChange;        
    end

    methods
        function obj = MSDAContainer(rawData,motionTest,varargin)
            obj.param = motionTest.dimension;
            obj.name = motionTest.name;
            obj.trajectory = rawData;
            obj.result = motionTest.result();
            obj.velocity = motionTest.rawDataArray;
            if ~isempty(varargin)
                obj.colorMap = varargin{1};
            end
            obj.currentPointIndex = obj.param * 2;           
        end
        function h = plotFullTrace(obj)
            h = plot(obj.trajectory(:,1),obj.trajectory(:,2));
            hold on;
            groupNum = length(obj.result);
            for m = 1:1:groupNum
                groupIndices = obj.result{m}(:,1);
                scatter(obj.trajectory(groupIndices,1),obj.trajectory(groupIndices,2),10,'filled','DisplayName',strcat('Group ',num2str(m)));
            end
            scatter(obj.trajectory(obj.currentPointIndex,1),obj.trajectory(obj.currentPointIndex,2),30,'k','filled','DisplayName','CurrentPoint');
            hold off;
        end
        function h = plotLocalTrace(obj,varargin)
            if ~isempty(varargin)
                cPI = varargin{1};
            else
                cPI = obj.currentPointIndex;
            end
            indexRange = obj.backward(cPI,-1,obj.param*2);
            h = plot(obj.trajectory(indexRange,1),obj.trajectory(indexRange,2));
            hold on;
            xRange = obj.range(obj.trajectory(indexRange,1));
            yRange = obj.range(obj.trajectory(indexRange,2));
            xlim(xRange);
            ylim(yRange);
            newResultCell = obj.filterCell(obj.range(indexRange));
            
            groupNum = length(newResultCell);
            for m = 1:1:groupNum
                groupIndices = newResultCell{m}(:,1);
                scatter(obj.trajectory(groupIndices,1),obj.trajectory(groupIndices,2),10,'filled','DisplayName',strcat('Group ',num2str(m)));
            end
            scatter(obj.trajectory(obj.currentPointIndex,1),obj.trajectory(obj.currentPointIndex,2),30,'k','filled','DisplayName','CurrentPoint');
            hold off;
        end
        function h = plotMSD(obj)
            data = [];
            while(isempty(data))
                count = length(obj.result);
                for m = 1:1:count
                    n = find(obj.result{m} == obj.currentPointIndex);
                    if ~isempty(n)
                        data = obj.result{m}(n,:);
                        break;
                    end
                end
            end
            if strcmp(obj.name,'MSD')
                h = plot(data(:,3:obj.param+2));
            else
                h = plot(data(:,2:obj.param+1));
            end
            
            hold off;
        end
        function h = plotVelocity(obj,isReserve)
            if isReserve
                tmp = xlim();
            end
            h = plot(1:length(obj.velocity),obj.velocity);
            hold on;
            groupNum = length(obj.result);
            for m = 1:1:groupNum
                groupIndices = obj.result{m}(:,1);
                scatter(groupIndices,obj.velocity(groupIndices),10,'filled','DisplayName',strcat('Group ',num2str(m)));
            end
            scatter(obj.currentPointIndex,obj.velocity(obj.currentPointIndex),30,'k','filled','DisplayName','CurrentPoint');
            hold off;
            if isReserve
                xlim(tmp);
            end
        end
        
        function changePoint(obj,index)
            if (index >= (obj.param * 2) && (index < length(obj.trajectory)))
                obj.currentPointIndex = index;
                obj.update(1);
            else
                errordlg('Error: Invalid Point!','MSD Analysis Container');
            end
        end
        
        function ran = range(obj,x)
            ran = zeros(1,2);
            ran(1) = min(x);
            ran(2) = max(x);
        end
        
        function x = backward(obj,begin,step,length)
            x = begin : step : (begin + step * (length - 1));
        end
        
        function b = isInRange(obj,value,range)
            b = value > range(1) & value < range(2);
        end
        
        function newCell = filterCell(obj,range)
            Csize = length(obj.result);
            newCell = cell(Csize);
            for m = 1:1:Csize
                validIndices = obj.isInRange(obj.result{m}(:,1),range);
                newCell{m} = obj.result{m}(validIndices,:);
            end
        end
        
        function update(obj,isReserve)
            subplot(2,4,[1,2,5,6]);
            obj.hFullTrace = obj.plotFullTrace();
            subplot(2,4,3);
            obj.hLocalTrace = obj.plotLocalTrace();
            subplot(2,4,4);
            obj.hMSD = obj.plotMSD();
            subplot(2,4,[7,8]);
            obj.hVelocity = obj.plotVelocity(isReserve);  
            title(strcat('Select Point: ',num2str(obj.currentPointIndex)));
        end
        
        function show(obj)
            obj.viewSize = get(0,'ScreenSize');
            obj.viewSize(4) = obj.viewSize(3)/2.3;
            obj.hFigure = figure('pos',obj.viewSize,'KeyReleaseFcn',@obj.onBlankSpaceRelease); 
            obj.update(0);
            obj.hClickButton = uicontrol('parent',obj.hFigure,'string','select','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49,80,49]);
            set(obj.hClickButton,'callback',@obj.onBlankSpaceRelease);
            obj.hNextButton = uicontrol('parent',obj.hFigure,'string','Next','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*2,80,49]);
            set(obj.hNextButton,'callback',@obj.onNext);
            obj.hLastButton = uicontrol('parent',obj.hFigure,'string','Last','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*3,80,49]);
            set(obj.hLastButton,'callback',@obj.onLast);
            obj.hEditBox = uicontrol('parent',obj.hFigure,'style','edit','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*4,80,49]);
            obj.hEnterButton = uicontrol('parent',obj.hFigure,'string','JumpTo','pos',[obj.viewSize(3) - 80,obj.viewSize(4) - 49*5,80,49]);
            set(obj.hEnterButton,'callback',@obj.onEnter);
        end
        
        function onBlankSpaceRelease(obj,varargin)
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
    end

end