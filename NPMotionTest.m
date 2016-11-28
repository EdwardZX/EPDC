classdef NPMotionTest
   
    properties
        iterationTime;
        timeDelay;
        dimension;
        k;
        rawDataArray;
        centricSet;
    end
    
    properties (Access = private)
        resultDataCell;
    end
  
    properties (Dependent)
        result;  
    end
    
    methods
        function obj = NPMotionTest(iT,tD,d,k,raw,result,cs)
            obj.iterationTime = iT;
            obj.timeDelay = tD;
            obj.dimension = d;
            obj.k = k;
            obj.rawDataArray = raw;
            obj.resultDataCell = result;
            obj.centricSet = cs;
        end        
        function [] = plot(obj)
            posMatrix = zeros(1,obj.k*3);
            for m=1:1:obj.k
                posMatrix((m-1)*3+1:m*3)=[1,2,3] + 4*(m-1);
            end
            subplot(obj.k,4,posMatrix);
            obj.plotTest();
            for m=1:1:obj.k
                subplot(obj.k,4,4*m);
                plot(obj.centricSet(m,:));
                title(strcat('Avarage curve for grounp',num2str(m)));
            end            
        end
        function [] = plotTest(obj,varargin)
            plot(obj.rawDataArray(:,1));
            hold on;
            if nargin == 2
                markerSize = varargin{1};
            else
                markerSize = 30;
            end
            for m = 1:1:obj.k
                scatter(obj.result{m}(:,1),obj.result{m}(:,2),markerSize,'filled','DisplayName',strcat('Group ',num2str(m)));
            end
            title(strcat('Test for TimeDelay =',num2str(obj.timeDelay),' Dimension =',num2str(obj.dimension),' k =',num2str(obj.k)));
            hold off;
        end   
        function res = getGroup(obj,k)
            res = obj.resultDataCell{k};
        end        
        function result = get.result(obj)
            result = obj.resultDataCell;
        end
    end
    
    
end

