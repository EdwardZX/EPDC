classdef SegShow < handle

    properties
        npRes,
        xy,
        vel,
        polar,
        xFunc,
        yFunc,
        segRes,
        offset,
        selectFrom,
        selectTo,
        selectIndices,
        activeIndex,
        isActivePlot
    end
    
    properties(Access=private)
        tolerence,
        cm,
        I,
        tmpI,
        tmpXData,
        tmpYData,
        xlabelName,
        ylabelName,
        holdPlotRange,
        holdLeftRange,
        plotType,
        hPa
        cachedDiffAlphaCell
    end
    
    properties(Dependent)
        isHoldingPlot
    end
    
    methods
        %label: vel   --  mean velocity
        %       pol   --  mean polar
        %       dff   --  diffusion coeff
        function obj = SegShow(r1,r2,segTolerence,polar)
            obj.npRes = {r1,r2};
            obj.xy = r1.xy;
            obj.vel = r1.velocity;
            obj.cachedDiffAlphaCell = {obj.cachedDA(r1.header),obj.cachedDA(r2.header)};
            obj.tolerence = segTolerence;
            obj.offset = [r1.header,r2.header];
            obj.polar = polar;
            obj.plotType = SegPlotType.NormalPlot;
            obj.xFunc = obj.dataEnum2func(SegAxisData.Velocity);
            obj.yFunc = obj.dataEnum2func(SegAxisData.Velocity);
            obj.xlabelName = SegShow.dataEnum2name(SegAxisData.Velocity);
            obj.ylabelName = SegShow.dataEnum2name(SegAxisData.Velocity);
            maxGroupNum = max([r1.k,r2.k]);
            obj.cm = [0,0,0;lines(maxGroupNum+1)];
            obj.cm(2,:) = [];
            obj.segRes = {tagSegFunc(r1.indexTag,obj.vel(r1.header:end),segTolerence,@(x)mean(x)),...
                          tagSegFunc(r2.indexTag,obj.vel(r2.header:end),segTolerence,@(x)mean(x))};
            obj.I = {SegShow.segCells2Index(obj.segRes{1}),...
                     SegShow.segCells2Index(obj.segRes{2})};
            obj.I{1} = [(0:1:maxGroupNum)';nan(r1.header-2-maxGroupNum,1);obj.I{1}];
            obj.I{2} = [(0:1:maxGroupNum)';nan(r2.header-2-maxGroupNum,1);obj.I{2}];
            obj.tmpI = obj.I;
            obj.holdPlotRange = [];
            obj.holdLeftRange = [];
            obj.selectFrom = -1;
            obj.selectTo = -1;
            obj.activeIndex = -1;
            obj.selectIndices = [];
            obj.show();
            obj.hPa = [];
            obj.isActivePlot = false;
        end
        
        function b = get.isHoldingPlot(obj)
            b = ~isempty(obj.holdPlotRange);
        end
        
        function onMainDraw(obj,hMain,hMain2)
            obj.drawLeft(hMain,obj.npRes{1});
            obj.drawLeft(hMain2,obj.npRes{2});
        end
        
        function onSegDraw(obj,hSeg,hSeg2)
            h1 = pcolor(hSeg,repmat(obj.tmpI{1}',10,1));
            h1.EdgeAlpha = 0;
            hSeg.XTickLabel = [];
            hSeg.YTickLabel = [];
            hSeg.XColor = [1,1,1];
            hSeg.YColor = [1,1,1];
            hSeg.Title.String = '';
            h2 = pcolor(hSeg2,repmat(obj.tmpI{2}',10,1));
            h2.EdgeAlpha = 0;
            hSeg2.XTickLabel = [];
            hSeg2.YTickLabel = [];
            hSeg2.XColor = [1,1,1];
            hSeg2.YColor = [1,1,1];
            hSeg2.Title.String = '';
            colormap(obj.cm);
        end
        
        function onPlotDraw(obj,handles)
            hPlot = handles.axes_plot;
            switch obj.plotType
                case SegPlotType.NormalPlot
                    plot(hPlot,obj.tmpXData,obj.tmpYData,'b-','LineWidth',2);
                    if and(strcmp(obj.xlabelName,'position x'),strcmp(obj.ylabelName,'position y'))
                        hPlot.NextPlot = 'add';
                        scatter(hPlot,obj.tmpXData(1),obj.tmpYData(1),20,'r','filled');
                        hPlot.NextPlot = 'replace';
                    end
                case SegPlotType.NormalScatter
                    scatter(hPlot,obj.tmpXData,obj.tmpYData,15,'r','filled');
                case SegPlotType.PolarScatter
                    if obj.isActivePlot
                        figure;
                        hp = polaraxes;
                        polarplot(hp,obj.tmpXData*pi/180,obj.tmpYData,'.','MarkerSize',15);
                        thetalim(hp,[0,90]);
                        title(hp,sprintf('From:%d,To:%d',obj.selectIndices(1),obj.selectIndices(2)));
                    end
                case SegPlotType.Histogram
                    hh = histogram(hPlot,obj.tmpXData,'Normalization','probability');
                    if ~isempty(obj.holdPlotRange)
                        hh.BinLimits = [obj.holdPlotRange(1,1),obj.holdPlotRange(1,2)];
                        hh.NumBins = 10;
                    end
                    
            end
            hPlot.Box = 'on';
            if and(~isempty(obj.holdPlotRange),obj.plotType ~= SegPlotType.PolarScatter)
%                 obj.onXRange(handles,obj.holdPlotRange(1,1),obj.holdPlotRange(1,2));
%                 obj.onYRange(handles,obj.holdPlotRange(2,1),obj.holdPlotRange(2,2));
                handles.axes_plot.XLim = [obj.holdPlotRange(1,1),obj.holdPlotRange(1,2)];
                handles.axes_plot.YLim = [obj.holdPlotRange(2,1),obj.holdPlotRange(2,2)];
            end
        end
        
        function onCopyFig(obj,hPlot)
            figure;
            scatter(axes,hPlot.Children.XData,hPlot.Children.YData,15,'r','filled');
            xlim( hPlot.XLim);
            ylim (hPlot.YLim);
            xlabel(obj.xlabelName);
            ylabel(obj.ylabelName);
            box on;
        end
        
        function onSegFrom(obj,num,handles)
            %keep in range
            if num <= 0
                num = 1;
            elseif num > length(obj.segRes{obj.activeIndex}.resCell)
                num = length(obj.segRes{obj.activeIndex}.resCell);
            end
            
            obj.selectFrom = num;
            handles.edt_segFrom.String = num2str(num);
            if num > obj.selectTo
                obj.onSegTo(num,handles)
            else
                obj.onSegSelect(handles,obj.selectFrom,obj.selectTo);
            end
        end
        
        function onSegTo(obj,num,handles)
            %keep in range
            if num <= 0
                num = 1;
            elseif num > length(obj.segRes{obj.activeIndex}.resCell)
                num = length(obj.segRes{obj.activeIndex}.resCell);
            end
            
            obj.selectTo = num;
            handles.edt_segTo.String = num2str(num);
            if num < obj.selectFrom
                obj.onSegFrom(num,handles)
                obj.onSegSelect(handles,obj.selectFrom,obj.selectTo);
                return;
            end  
            if obj.selectFrom < 0
                obj.onSegFrom(1,handles)
                obj.onSegSelect(handles,obj.selectFrom,obj.selectTo);
                return;
            end
            obj.onSegSelect(handles,obj.selectFrom,obj.selectTo);
        end
        
        function onSegSelect(obj,handles,from,to)
            startAt = obj.segRes{obj.activeIndex}.resCell{from}(3)...
                      + obj.offset(obj.activeIndex) - 1;
            endAt = obj.segRes{obj.activeIndex}.resCell{to}(4)...
                      + obj.offset(obj.activeIndex) - 1;
            obj.selectIndices = [startAt,endAt];
            obj.tmpI = obj.I;
            obj.tmpI{1}(startAt:endAt) = 0;
            obj.tmpI{2}(startAt:endAt) = 0;
            obj.onSegDraw(handles.axes_seg,handles.axes_seg_2);
            obj.onMainDraw(handles.axes_main,handles.axes_main_2);
            
            obj.tmpXData = obj.xFunc(startAt,endAt); %global index
            obj.tmpYData = obj.yFunc(startAt,endAt); %global index
            obj.onPlotDraw(handles);        
        end
                
        function onXRange(obj,handles,from,to)
            if obj.plotType ~= SegPlotType.PolarScatter
                handles.axes_plot.XLim = [from,to];
            end
            
            if obj.isHoldingPlot
                obj.onHoldRange(handles.btn_hold,handles.axes_plot);
            end
                
        end
        
        function onYRange(obj,handles,from,to)
            if obj.plotType ~= SegPlotType.PolarScatter
                handles.axes_plot.YLim = [from,to];
            end
            
            if obj.isHoldingPlot
                obj.onHoldRange(handles.btn_hold,handles.axes_plot);
            end
        end
        
        function onHoldRange(obj,hBtn,hPlot)
            if isempty(obj.holdPlotRange)
                hBtn.BackgroundColor = [0.47,0.67,0.19];
                obj.holdPlotRange = [hPlot.XLim;hPlot.YLim];
            else
                hBtn.BackgroundColor = [1,1,1];
                obj.holdPlotRange = [];
            end
        end
        
        function onHoldTrace(obj,hBtn,hPlot)
            if isempty(obj.holdLeftRange)
                hBtn.BackgroundColor = [0.47,0.67,0.19];
                obj.holdLeftRange = hPlot.XLim;
            else
                hBtn.BackgroundColor = [1,1,1];
                obj.holdLeftRange = [];
            end
        end
        
        function onPlotTypeSelected(obj,type,handles)
            switch(type)
                case 1
                    obj.plotType = SegPlotType.NormalPlot;
                    handles.pop_yData.Enable = 'on';
                    if obj.isActivePlot
                        obj.onActivePlot(handles.btn_active);
                    end
                    handles.btn_active.Enable = 'off';
%                     if obj.hPa
%                         obj.hPa.Visible = 'off';
%                     end
%                     handles.axes_plot.Visible = 'on';
                case 2
                    obj.plotType = SegPlotType.NormalScatter;
                    handles.pop_yData.Enable = 'on';
                    if obj.isActivePlot
                        obj.onActivePlot(handles.btn_active);
                    end
                    handles.btn_active.Enable = 'off';
%                     if obj.hPa
%                         obj.hPa.Visible = 'off';
%                     end
%                     handles.axes_plot.Visible = 'on';
                case 3
                    obj.plotType = SegPlotType.PolarScatter;
                    handles.pop_yData.Enable = 'on';
                    handles.btn_active.Enable = 'on';
%                     if isempty(obj.hPa)
%                         obj.hPa = polaraxes('Parent',handles.figure1,...
%                                             'Position',handles.axes_plot.Position);
%                     end
%                     handles.axes_plot.Visible = 'off';
%                     obj.hPa.Visible = 'on';
                case 4
                    obj.plotType = SegPlotType.Histogram;
                    handles.pop_yData.Enable = 'off';
                    if obj.isActivePlot
                        obj.onActivePlot(handles.btn_active);
                    end
                    handles.btn_active.Enable = 'off';
%                     if obj.hPa
%                         obj.hPa.Visible = 'off';
%                     end
%                     handles.axes_plot.Visible = 'on';
            end
            if obj.isHoldingPlot
                obj.onHoldRange(handles.btn_hold,handles.axes_plot);
            end
            obj.onPlotDraw(handles);
        end
        
        function onXDataType(obj,type,handles)
            switch(type)
                case 1
                    type = SegAxisData.Velocity;
                case 2
                    type = SegAxisData.Polar;
                case 3
                    type = SegAxisData.PosX;
                case 4
                    type = SegAxisData.PosY;
                case 5
                    type = SegAxisData.HistDiff;
                case 6
                    type = SegAxisData.HistAlpha;
            end
            obj.xFunc = obj.dataEnum2func(type);
            obj.tmpXData = obj.xFunc(obj.selectIndices(1),obj.selectIndices(2));
            obj.xlabelName = SegShow.dataEnum2name(type);
            obj.onPlotDraw(handles);
        end
        
        function onYDataType(obj,type,handles)
             switch(type)
                case 1
                    type = SegAxisData.Velocity;
                case 2
                    type = SegAxisData.Polar;
                case 3
                    type = SegAxisData.PosX;
                case 4
                    type = SegAxisData.PosY;
                case 5
                    type = SegAxisData.HistDiff;
                case 6
                    type = SegAxisData.HistAlpha;
            end
            obj.yFunc = obj.dataEnum2func(type);
            obj.tmpYData = obj.yFunc(obj.selectIndices(1),obj.selectIndices(2));
            obj.ylabelName = SegShow.dataEnum2name(type);
            obj.onPlotDraw(handles);
        end
        
        function onSwitchMain(obj,handles,index)
            if index == obj.activeIndex
                return;
            end
            obj.activeIndex = index;
            if index == 1
                handles.btn_curFigIndicator_1.BackgroundColor = [0.47,0.67,0.19];
                handles.btn_curFigIndicator_2.BackgroundColor = [0.85,0.33,0.1];
            else
                handles.btn_curFigIndicator_2.BackgroundColor = [0.47,0.67,0.19];
                handles.btn_curFigIndicator_1.BackgroundColor = [0.85,0.33,0.1];
            end
            if ~isempty(obj.selectIndices)
                obj.selectFrom = obj.absIndex2groundIndex(obj.selectIndices(1));
                obj.selectTo = obj.absIndex2groundIndex(obj.selectIndices(2));
                handles.edt_segFrom.String = num2str(obj.selectFrom);
                handles.edt_segTo.String = num2str(obj.selectTo);
                obj.onSegSelect(handles,max(obj.selectFrom,1),...
                                        min(obj.selectTo,length(obj.segRes{index}.resCell)));
            end
        end
        
        function onActivePlot(obj,hBtn,handles)
            if obj.isActivePlot
                hBtn.BackgroundColor = [1,1,1];
                obj.isActivePlot = false;
            else
                hBtn.BackgroundColor = [0.47,0.67,0.19];
                obj.isActivePlot = true;
                obj.onPlotDraw(handles);
            end
        end
    end
    
    methods(Access=private)
        function show(obj)
            SegShowUI(obj);
        end
        function drawLeft(obj,hA,r)
            cla(hA);
            hA.NextPlot = 'add';
            r.plotTest(hA,r.rawData);
            xlim(hA,[1,length(r.rawData)]);
            if obj.selectFrom > 0
                tmpY = hA.YLim;
                line(hA,ones(1,2)*obj.selectIndices(1),tmpY,...
                    'LineWidth',1,'Color',[1,0,0],'LineStyle','--');
                line(hA,ones(1,2)*obj.selectIndices(2),tmpY,...
                    'LineWidth',1,'Color',[1,0,0],'LineStyle','--');
            end
            if ~isempty(obj.holdLeftRange)
                hA.XLim = obj.holdLeftRange;
            end
            hA.Title.String = '';
            hA.NextPlot = 'replace';
        end
        function hFunc = dataEnum2func(obj,str)
            switch(str)
                case SegAxisData.Velocity
                    hFunc = @obj.getVelocity;
                case SegAxisData.Polar
                    hFunc = @obj.getPolar;
                case SegAxisData.PosX
                    hFunc = @obj.getPosX;
                case SegAxisData.PosY
                    hFunc = @obj.getPosY;
                case SegAxisData.HistDiff
                    hFunc = @obj.getDiff;
                case SegAxisData.HistAlpha
                    hFunc = @obj.getAlpha;
            end
        end
        function plotData = getPosX(obj,startAt,endAt)
            plotData = obj.xy(startAt:endAt,1);
        end
        function plotData = getPosY(obj,startAt,endAt)
            plotData = obj.xy(startAt:endAt,2);
        end
        function plotData = getVelocity(obj,startAt,endAt)
            plotData = obj.vel(startAt:endAt);
        end
        function plotData = getPolar(obj,startAt,endAt)
            plotData = obj.polar(startAt:endAt);
        end
        function d_al = cachedDA(obj,offset)
            L = length(obj.xy);
            d_al = zeros(L,2);
            n = 1;
            hBar = waitbar(0,'Caching D & alpha...');
            for m = offset:L
                histXY = obj.xy((m-offset+1):m,:);
                tmp = SegShow.trace2diffAlpha(histXY);
                d_al(m,:) = tmp;
                waitbar(n/(L-offset),hBar);
                n = n+1;
            end
            close(hBar);
%             L = length(obj.segRes.resCell);
%             plotData = [];
%             for m = 1:1:L
%                 data = obj.segRes.resCell{m};
%                 if (data(4)+obj.offset-1) <= startAt
%                     continue;
%                 elseif and((data(3)+obj.offset-1)>= startAt,...
%                            (data(4)+obj.offset-1)<=endAt)
%                     trace = obj.xy(startAt:endAt,:);
%                     plotData = [plotData,SegShow.trace2dff(trace)];
%                 elseif (data(3)+obj.offset-1)>= startAt
%                      break;
%                 end
%             end
        end
        function plotData = getDiff(obj,startAt,endAt)
            plotData  = obj.cachedDiffAlphaCell{obj.activeIndex}(startAt:endAt,1);
        end
        function plotData = getAlpha(obj,startAt,endAt)
            plotData  = obj.cachedDiffAlphaCell{obj.activeIndex}(startAt:endAt,2);
        end
        function num = absIndex2groundIndex(obj,absI)
            cells = obj.segRes{obj.activeIndex}.resCell;
            relI = absI - obj.offset(obj.activeIndex) + 1;
            L = length(cells);
            for m = 1:1:L
                if and(relI>=cells{m}(3),relI<=cells{m}(4))
                    num = m;
                    return;
                end
            end
        end
    end
    
    methods(Static)
        function [I] = segCells2Index(segRes)
            I = nan(segRes.length,1);
            L = length(segRes.resCell);
            for m = 1:1:L
                data = segRes.resCell{m};
                I(data(3):data(4)) = data(2);
            end
        end
        function nameStr = dataEnum2name(label)
            switch(label)
                case SegAxisData.Velocity
                    nameStr = 'velocity';
                case SegAxisData.Polar
                    nameStr = 'polar angle';
                case SegAxisData.PosX
                    nameStr = 'position x';
                case SegAxisData.PosY
                    nameStr = 'position y';
                case SegAxisData.HistDiff
                    nameStr = 'Diffusion Coefficient';
                case SegAxisData.HistAlpha
                    nameStr = '$\alpha$';
                    
            end
        end
        function d_al = trace2diffAlpha(xy)
            L = length(xy);
            lag = round(L/3);
            msd_curve = msd(xy,lag);
            d_al = nlinfit((1:lag)'*0.07,msd_curve,@(b,x)4*b(1)*power(x,b(2)),[0.1,1]);           
        end
        function alpha = trace2alpha(xy)
            L = length(xy);
            lag = round(L/3);
            msd_curve = msd(xy,lag);
            d_al = nlinfit((1:lag)'*0.07,msd_curve,@(b,x)4*b(1)*power(x,b(2)),[0.1,1]);
            alpha = d_al(2);
        end
    end
    
end

