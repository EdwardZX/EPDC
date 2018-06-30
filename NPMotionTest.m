classdef NPMotionTest < handle
   
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
        rawData;
        probMat;
    end
    
    properties (Access = private)
        resultData;
    end
    
    properties(Dependent)
        totalDistance;
    end
     
    methods
        function obj = NPMotionTest(analysisMethod,xy,raw,resultData,indexTag,header,centric,velocity,tau,D,k,prob)
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
            obj.rawData = raw;
            obj.probMat = prob;
        end     
        % plotC: plot centric in one axes
        function h = plotC(obj)
            figure;
            c = lines(obj.k + 1);
            if obj.dimension > 1
                if strcmp(obj.analysisMethod,'msd')
                    plot(obj.centric(1,:),'DisplayName','Group:1','Color',c(2,:),'LineWidth',3);
                elseif strcmp(obj.analysisMethod,'autoc')
                    plot(0:1:obj.dimension,obj.centric(1,:),'DisplayName','Group:1','Color',c(2,:),'LineWidth',3);
                else
                    plot(1:1:obj.dimension,obj.centric(1,end:-1:1),'DisplayName','Group:1','Color',c(2,:),'LineWidth',3);     
                end                 
            else
                scatter(1,obj.centric(1),30,c(2,:),'filled','DisplayName','Group:1');
            end
            hold on;
            for m = 2:1:obj.k
                if obj.dimension > 1
                    if strcmp(obj.analysisMethod,'msd')
                        plot(obj.centric(m,:),'DisplayName',strcat('Group:',num2str(m)),'Color',c(m+1,:),'LineWidth',3);
                    elseif strcmp(obj.analysisMethod,'autoc')
                        plot(0:1:obj.dimension,obj.centric(m,:),'DisplayName',strcat('Group:',num2str(m)),'Color',c(m+1,:),'LineWidth',3);
                    else
                        plot(1:1:obj.dimension,obj.centric(m,end:-1:1),'DisplayName',strcat('Group:',num2str(m)),'Color',c(m+1,:),'LineWidth',3);
                    end 
                else
                    scatter(1,obj.centric(m),30,c(m+1,:),'filled','DisplayName',strcat('Group:',num2str(m)));
                end
            end
            hold off;
            box on;
            if strcmp(obj.analysisMethod,'autoc')
                xlim([0,obj.dimension])
            else
                xlim([1,obj.dimension]);
            end
            if ~strcmp(obj.analysisMethod,'msd')
                xlabel('Ordered Time-dependent Feature Vector');
            else
                xlabel('Time lag')
            end
            legend('show');
        end
        
        function sumDis = get.totalDistance(obj)
            % code need to be optimized
            sumDis = 0;
            for m = 1:1:obj.k
                sumDis = sumDis + sum(pdist2(obj.centric(m,:),obj.resultData(obj.indexTag==m,:)));
            end
        end

        function [] = mergeGroup(obj,g1,g2)
            if and(and(g1 > 0 , g2 > 0),and(g1 <= obj.k,g2<=obj.k))
                numG1 = length(obj.indexTag(obj.indexTag == g1));
                numG2 = length(obj.indexTag(obj.indexTag == g2));
                if and(numG1>0,numG2>0)
                    obj.indexTag(obj.indexTag == g2) = g1;
                    obj.k = obj.k - 1;
                    tmp = obj.centric(g2,:);
                    obj.centric(g2,:) = [];
                    obj.centric(g1,:) = (obj.centric(g1,:) * numG1 + tmp * numG2)/(numG1 + numG2);
                else
                    disp('ERROR: invalid group index!');
                end
            else
                disp('ERROR: input invalid parameter!');
            end
        end
        % plot(bgData = velocity,grounpIndex = all);
        
        function [] = autoMergeGroup(obj,meanThres,corrThres)
            for m = 1:1:(obj.k - 1)
                for n = (m + 1):1:obj.k
                    meanDiff = abs(mean(obj.centric(m,:)) - mean(obj.centric(n,:)));
                    cor = abs(corrcoef(obj.centric(m,:),obj.centric(n,:)));
                    cor = cor(2);
                    if and(meanDiff < (range(obj.centric(:)) * meanThres), cor > corrThres)
                        plot(obj.centric(m,:));
                        hold on;
                        plot(obj.centric(n,:));
                        ylim([min(obj.centric(:)),max(obj.centric(:))]);
                        hold off;
                        pause;
                        fprintf(1,'Group: %d,%d: meanDiff: %.3f, corr: %.3f\n',m,n,meanDiff/range(obj.centric(:)),cor);
                        obj.mergeGroup(m,n);
                        obj.autoMergeGroup(meanThres,corrThres);
                        break;
                    end
                end
            end
            fprintf('Done!\n');
        end
        
        function [] = plot(obj,varargin)
            figure;
            if nargin >= 2
                bgData = varargin{1};
            else
                bgData = obj.velocity;
            end
            if obj.dimension <= 1
                obj.plotTest(gca,bgData);
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
            if strcmp(obj.analysisMethod,'uni')
                h = plot(hAxes,obj.centric(m,end:-1:1));
            else
                h = plot(hAxes,obj.centric(m,:));
            end
            title(strcat('Avarage curve for grounp',num2str(m)));
            xlim([1,size(obj.centric,2)]);
        end
        
        % plotTest(hAxes,bgData,grounpIndex = all)
        function [] = plotTest(obj,hAxes,bgData,varargin)
            if size(bgData,2) > 1
                bgData = obj.velocity;
            end
            plot(hAxes,bgData,'DisplayName','velocity of NP');
            hold on;
            markerSize = 10;
            if nargin == 4
                [~,I] = obj.getResult(varargin{1});
                scatter(hAxes,I,bgData(I),markerSize,'filled','DisplayName',strcat('Group ',num2str(varargin{1})));
            else
                for m = 1:1:obj.k
                    [~,I] = obj.getResult(m);
                    scatter(hAxes,I,bgData(I),markerSize,'filled','DisplayName',strcat('Group ',num2str(m)));
                end
            end
            
            title(hAxes,strcat(obj.analysisMethod,32,'test for TimeDelay =',num2str(obj.timeDelay),' Dimension =',num2str(obj.dimension),' k =',num2str(obj.k)));
            hold off;
            xlim([1,length(bgData)]);
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
            [r,I] = obj.getResult(varargin{:});
            indexResult = [I',r];
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
            elseif nargin == 2
                minRange = varargin{1};
                maxRange = length(obj.velocity);
            else
                minRange = obj.header;
                maxRange = length(obj.velocity);
            end
            if minRange < obj.header
                disp('ERROR: minRange input is smaller than header index!');
                disp(strcat('Header:',num2str(obj.header)));
            end
            tmpMin = minRange;
            tmpMax = maxRange;
            figure;
            counts = zeros(obj.k,1);
            minRange = obj.abs2rel(minRange);
            maxRange = obj.abs2rel(maxRange);
            data = obj.indexTag(minRange:maxRange);
            dataLength = size(data,1);
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
            title(['Histogram of the count of different Group from time index ' num2str(tmpMin) ' to ' num2str(tmpMax)]);
            set(gca,'XTick',1:1:obj.dimension);
            hold off;
        end
        function plotEmpTrace(obj,groupIndex,varargin)
            if isempty(varargin)
                figure;
                hA = axes;
                hold on;
            else
                hA = varargin{1};
                hold on;
            end
            c = lines(obj.k + 1);
            tmp = 1:1:size(obj.xy,1);
            targetIndex = tmp(logical([zeros(1,obj.header-1),(obj.indexTag==groupIndex)]));
            for m = 1:1:length(targetIndex)
                ender = targetIndex(m);
                starter = ender - obj.header + 1;
                tmpXY = obj.xy(starter:ender,:);
                tmpXY = tmpXY - tmpXY(1,:);
                plot(hA,tmpXY(:,1),tmpXY(:,2),'Color',c(groupIndex + 1,:));
            end
            box on;
        end
        
        function tmp = reClass(obj,linker,k,comd,p,optTime)
            [I,C,~] = optKMeans(obj.resultData,k,comd,p,optTime,linker);
            tmp = NPMotionTest('uni',obj.xy,obj.resultData,I,obj.header,C,obj.velocity,obj.timeDelay,obj.dimension,obj.k);
            subplot(2,1,1);
            obj.plotTest(gca,obj.velocity);
            title('Origin class result');
            subplot(2,1,2);
            tmp.plotTest(gca,obj.velocity);
            title(strcat('Origin class result, optimization times:',32,num2str(optTime)));
        end
        
        function nanProbUnder(obj,thres)
            maxProb = max(obj.probMat);
            obj.indexTag(maxProb<thres) = nan;
        end
        
        function plotProb(obj)
            figure; hold on;
            c = lines(obj.k+1);
            for m = 1:1:obj.k
                plot(obj.probMat(m,:),'Color',c(m+1,:),'LineWidth',1);
            end
        end
    end    
    
end
