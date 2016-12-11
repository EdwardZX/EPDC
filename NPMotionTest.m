classdef NPMotionTest
   
    properties
        timeDelay;
        dimension;
        k;
        xy;
        velocity;
        analysisMethod;
        header;
        realIndex;
        indexTag;
        centric;
    end
    
    properties (Access = private)
        resultData;
    end
     
    methods
        function obj = NPMotionTest(analysisMethod,xy,resultData,indexTag,header,centric,velocity,tau,D,k)
            obj.timeDelay = tau;
            obj.dimension = D;
            obj.k = k;
            obj.xy = xy;
            obj.velocity = velocity;
            obj.analysisMethod = analysisMethod;
            obj.resultData = resultData;
            obj.indexTag = indexTag;
            obj.header = header;
            obj.realIndex = header:1:(size(resultData,1) + header - 1);
            obj.centric = centric;
        end      
        
        function [] = plot(obj)
            figure;
            posMatrix = zeros(1,obj.k*3);
            for m=1:1:obj.k
                posMatrix((m-1)*3+1:m*3)=[1,2,3] + 4*(m-1);
            end
            subplot(obj.k,4,posMatrix);
            obj.plotTest();
            for m=1:1:obj.k
                subplot(obj.k,4,4*m);
                plot(obj.centric(m,:));
                title(strcat('Avarage curve for grounp',num2str(m)));
                xlim([1,size(obj.centric,2)]);
            end            
        end
        
        function [] = plotTest(obj)
            plot(obj.velocity,'DisplayName','velocity of NP');
            hold on;
            markerSize = 30;
            for m = 1:1:obj.k
                [~,I] = obj.getResult(m);
                scatter(I,obj.velocity(I),markerSize,'filled','DisplayName',strcat('Group ',num2str(m)));
            end
            title(strcat(obj.analysisMethod,'test for TimeDelay =',num2str(obj.timeDelay),' Dimension =',num2str(obj.dimension),' k =',num2str(obj.k)));
            hold off;
        end   
           
        function [result,Index] = getResult(obj,varargin)
            if isempty(varargin)
                Index = obj.realIndex;
                result = obj.resultData;
            else if and(varargin{1} > 0,varargin{1} <= obj.k)
                Index = obj.realIndex(obj.indexTag == varargin{1});
                result = obj.resultData(obj.indexTag == varargin{1},:);
                end
            end          
        end

        function [indexResult] = getIndexResult(obj,varargin)
            indexResult = zeros(size(obj.resultData) + [0,1]);
            [r,I] = obj.getResult(varargin);
            indexResult(:,1) = I;
            indexResult(:,2:end) = r;
        end

        function [data] = getResultAt(obj,indices)
            data = obj.resultData(indices,:);
        end
        function relIndex = abs2rel(obj,absIndex)
            relIndex = absIndex - obj.header + 1;
        end
        function h = tagHist(obj,minRange,maxRange)
            if minRange < obj.header
                disp('ERROR: minRange input is smaller than header index!');
                disp(strcat('Header:',num2str(obj.header)));
            end
            figure;
            minRange = obj.abs2rel(minRange);
            maxRange = obj.abs2rel(maxRange);
            data = obj.indexTag(minRange:maxRange);
            dataLength = size(data,2);
            c = lines(obj.k + 1);
            %h = histogram(data(data == 1),'DisplayName','Group:1');
            h = bar(1,sum(data==1) * 100/dataLength,'DisplayName','Group:1','BarWidth',1,'FaceColor',c(2,:));
            hold on;
            for m = 2:1:obj.k
                %h = histogram(data(data == m),'DisplayName',strcat('Group:',num2str(m)));
                bar(m,sum(data==m) * 100/dataLength,'DisplayName',strcat('Group:',num2str(m)),'BarWidth',1,'FaceColor',c(m + 1,:));
            end
            xlabel('Group Index of K-means');
            ylabel('percentage in selected range ( % )');
            hold off;
        end
    end
    
    
end

