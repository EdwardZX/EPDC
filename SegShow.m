classdef SegShow < handle

    properties
        npRes,
        xy,
        vel,
        polar,
        xFunc,
        yFunc,
        segRes,
        offset
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
        holdRange
    end
    
    methods
        %label: vel   --  mean velocity
        %       pol   --  mean polar
        %       dff   --  diffusion coeff
        function obj = SegShow(r,segTolerence,offset,polar,xLabel,yLabel)
            obj.npRes = r;
            obj.xy = r.xy;
            obj.vel = r.velocity;
            obj.tolerence = segTolerence;
            obj.offset = offset;
            obj.polar = polar;
            obj.xFunc = obj.str2func(xLabel);
            obj.yFunc = obj.str2func(yLabel);
            obj.xlabelName = SegShow.label2name(xLabel);
            obj.ylabelName = SegShow.label2name(yLabel);
            obj.cm = [0,0,0;lines(6)];
            obj.cm(2,:) = [];
            obj.segRes = tagSegFunc(r.indexTag,obj.npRes.velocity(offset:end),segTolerence,@(x)mean(x));
            obj.I = SegShow.segCells2Index(obj.segRes);
            obj.I = [nan(obj.offset-2,1);0;obj.I];
            obj.tmpI = obj.I;
            obj.holdRange = [];
            obj.show();
        end
        
        function onMainDraw(obj,hMain)
            hMain.NextPlot = 'add';
            obj.npRes.plotTest(hMain,obj.vel);
            xlim([1,length(obj.vel)]);
            hMain.NextPlot = 'replace';
        end
        
        function onSegDraw(obj,hSeg)
            h = pcolor(hSeg,repmat(obj.tmpI',10,1));
            h.EdgeAlpha = 0;
            %axis off;
            colormap(obj.cm);
        end
        
        function onPlotDraw(obj,hPlot)
            scatter(hPlot,obj.tmpXData,obj.tmpYData,15,'r','filled');
            xlabel(obj.xlabelName);
            ylabel(obj.ylabelName);
            hPlot.Box = 'on';
            if ~isempty(obj.holdRange)
                obj.onXRange(hPlot,obj.holdRange(1,1),obj.holdRange(1,2));
                obj.onYRange(hPlot,obj.holdRange(2,1),obj.holdRange(2,2));
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
        
        function onSegSelect(obj,hSeg,hPlot,from,to)
            startAt = obj.segRes.resCell{from}(3) + obj.offset - 1;
            endAt = obj.segRes.resCell{to}(3) + obj.offset - 1;
            obj.tmpI = obj.I;
            obj.tmpI(startAt:endAt) = 0;
            obj.onSegDraw(hSeg);
            obj.tmpXData = obj.xFunc(startAt,endAt); %global index
            obj.tmpYData = obj.yFunc(startAt,endAt); %global index
            obj.onPlotDraw(hPlot);        
        end
        
        function onXRange(obj,hPlot,from,to)
            hPlot.XLim = [from,to];
        end
        
        function onYRange(obj,hPlot,from,to)
            hPlot.YLim = [from,to];
        end
        
        function onHoldRange(obj,hBtn,hPlot)
            if isempty(obj.holdRange)
                hBtn.BackgroundColor = [0.47,0.67,0.19];
                obj.holdRange = [hPlot.XLim;hPlot.YLim];
            else
                hBtn.BackgroundColor = [1,1,1];
                obj.holdRange = [];
            end
        end
        
    end
    
    methods(Access=private)
        function show(obj)
            SegShowUI(obj);
        end
        function hFunc = str2func(obj,str)
            switch(str)
                case 'vel'
                    hFunc = @obj.getVelocity;
                case 'pol'
                    hFunc = @obj.getPolar;
                case 'dff'
                    hFunc = @obj.getDiff;
            end
        end
        function plotData = getVelocity(obj,startAt,endAt)
            plotData = obj.vel(startAt:endAt);
        end
        function plotData = getPolar(obj,startAt,endAt)
            plotData = obj.polar(startAt:endAt);
        end
        function plotData = getDiff(obj,startAt,endAt)
            L = length(obj.segRes.resCell);
            plotData = [];
            for m = 1:1:L
                data = obj.segRes.resCell{m};
                if (data(4)+obj.offset-1) <= startAt
                    continue;
                elseif and((data(3)+obj.offset-1)>= startAt,...
                           (data(4)+obj.offset-1)<=endAt)
                    trace = obj.xy(startAt:endAt,:);
                    plotData = [plotData,SegShow.trace2dff(trace)];
                elseif (data(3)+obj.offset-1)>= startAt
                     break;
                end
            end
        end
    end
    
    methods(Static)
        function [I] = segCells2Index(segRes)
            I = zeros(segRes.length,1);
            L = length(segRes.resCell);
            for m = 1:1:L
                data = segRes.resCell{m};
                I(data(3):data(4)) = data(2);
            end
        end
        function nameStr = label2name(label)
            switch(label)
                case 'vel'
                    nameStr = 'velocity';
                case 'pol'
                    nameStr = 'polar angle';
                case 'dff'
                    nameStr = 'diffuse coeff';
            end
        end
        function d = trace2dff(xy)
            L = length(xy);
            lag = round(L/3);
            msd_curve = msd(xy,lag);
            d_al = nlinfit((1:lag)'*0.07,msd_curve,@(b,x)4*b(1)*power(x,b(2)),[0.1,1]);
            d = d_al(1);
        end
    end
    
end

