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
        % plotC: plot centric in one axes
        function h = plotC(obj)
            figure;
            c = lines(obj.k + 1);
            plot(obj.centric(1,:),'DisplayName','Group:1','Color',c(2,:),'LineWidth',3);
            hold on;
            for m = 2:1:obj.k
                plot(obj.centric(m,:),'DisplayName',strcat('Group:',num2str(m)),'Color',c(m+1,:),'LineWidth',3);
            end
            hold off;
        end
        % plot(bgData = velocity,grounpIndex = all);
        function [] = plot(obj,varargin)
            figure;
            if nargin >= 2
                bgData = varargin{1};
            else
                bgData = obj.velocity;
            end
            if obj.dimension <= 1
                obj.plotTest(bgData);
                return;
            end
            posMatrix = zeros(1,obj.k*3);
            for m=1:1:obj.k
                posMatrix((m-1)*3+1:m*3)=[1,2,3] + 4*(m-1);
            end
            hA = subplot(obj.k,4,posMatrix);
            if nargin == 3
                obj.plotTest(hA,bgData,varargin{2});
            else
                obj.plotTest(hA,bgData);
            end
            for m=1:1:obj.k
                hA = subplot(obj.k,4,4*m);
                obj.plotSingleCentric(hA,m);
            end            
        end
        
        function h = plotSingleCentric(obj,hAxes,m)
            if obj.analysisMethod == 'uni'
                h = plot(hAxes,obj.centric(m,end:-1:1));
            else
                h = plot(hAxes,obj.centric(m,:));
            end
            title(strcat('Avarage curve for grounp',num2str(m)));
            xlim([1,size(obj.centric,2)]);
        end
        
        % plotTest(hAxes,bgData,grounpIndex = all)
        function [] = plotTest(obj,hAxes,bgData,varargin)
            plot(hAxes,bgData,'DisplayName','velocity of NP');
            hold on;
            markerSize = 30;
            if nargin == 4
                [~,I] = obj.getResult(varargin{1});
                scatter(hAxes,I,bgData(I),markerSize,'filled','DisplayName',strcat('Group ',num2str(varargin{1})));
            else
                for m = 1:1:obj.k
                    [~,I] = obj.getResult(m);
                    scatter(hAxes,I,bgData(I),markerSize,'filled','DisplayName',strcat('Group ',num2str(m)));
                end
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
        function [h,counts,dataLength] = tagHist(obj,varargin)
            if nargin == 3
                minRange = varargin{1};
                maxRange = varargin{2};
            else
                minRange = obj.header;
                maxRange = length(obj.velocity);
            end
            if minRange < obj.header
                disp('ERROR: minRange input is smaller than header index!');
                disp(strcat('Header:',num2str(obj.header)));
            end
            figure;
            counts = zeros(obj.k,1);
            minRange = obj.abs2rel(minRange);
            maxRange = obj.abs2rel(maxRange);
            data = obj.indexTag(minRange:maxRange);
            dataLength = size(data,2);
            c = lines(obj.k + 1);
            counts(1) = sum(data==1);
            h = bar(1,counts(1) * 100/dataLength,'DisplayName','Group:1','BarWidth',1,'FaceColor',c(2,:));
            hold on;
            for m = 2:1:obj.k
                counts(m) = sum(data==m);
                bar(m,counts(m) * 100/dataLength,'DisplayName',strcat('Group:',num2str(m)),'BarWidth',1,'FaceColor',c(m + 1,:));
            end
            xlabel('Group Index of K-means');
            ylabel('percentage in selected range ( % )');
            title(['Histogram of the count of different Group from time index ' num2str(minRange) ' to ' num2str(maxRange)]);
            hold off;
        end
    end    
    
end
