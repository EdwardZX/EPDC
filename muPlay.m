classdef muPlay < handle
    
    properties
        pResult,
        sampleRate,
        curPoint,
        hData
    end
    
    methods
        function obj = muPlay(r,fs)
            obj.pResult = r;
            if ~exist('fs','var')
                obj.sampleRate = 4410;
            else
                obj.sampleRate = fs;
            end
            obj.curPoint = 0;
            obj.hData = muPlayView(obj);
        end
        
        function onPlay(obj)
            yRange = obj.hData.axes1.YLim;
            obj.hData.axes1.NextPlot = 'add';
            hLine = plot(obj.curPoint*ones(2,1),yRange,'r','LineWidth',2);
            L = size(obj.pResult.rawData,1);
            tic;
            sound(obj.pResult.rawData,obj.sampleRate);
            disp(toc*obj.sampleRate<L);
            while(toc*obj.sampleRate<L)
                hLine.XData = toc*obj.sampleRate*ones(2,1); drawnow;
            end
            delete(hLine);
        end
        
        function res = onFSSet(obj,numstr)
            num = str2double(numstr);
            if num
                res = 1;
                obj.sampleRate = num;
            else
                res = 0;
            end
        end
    end
    
end

