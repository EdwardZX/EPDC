classdef MultiPro < handle
    %MultiPro : Multi-Particle Processor
    properties
        particleIds;
        pResult;
    end
    
    properties (Access = private)
        rawData;
        rawXY;
        dataDim;   
        dataLength;
        velocityCell;
        secondaryData;
        secondaryLength;
        secondaryHeader;
        secondaryIndex;
        kMeansCentrality;
        param;
    end
    
    properties (Dependent)
        particleNum;
        totalLength;
        centrality;
        timeDelay;
        dimension;
        k;
        distanceScale;
    end
    
    methods
        function obj = MultiPro()
            obj.rawData = [];
            obj.dataDim = 0;
            obj.particleIds = {};
            obj.dataLength = [];
            obj.rawXY = [];
            obj.velocityCell = {};
            obj.secondaryData = [];
            obj.secondaryLength = [];
            obj.secondaryHeader = [];
            obj.param = 0;
        end
        
        function addParticle(obj,xy,data,varargin)
            if isempty(varargin)
                id = strcat('Particle',32,num2str(obj.particleNum + 1));
            else
                id = varargin{1};
            end
            
            if class(id)~='char'
                disp('ERROR: particle id should be char(in MATLAB)!');
                return;
            end
            
            [newLength,newDim] = size(data);
            
            if or(obj.dataDim == newDim,obj.dataDim == 0)
                obj.dataDim = newDim;
                obj.particleIds{end+1} = id;
                obj.rawData = [obj.rawData;data];
                obj.rawXY = [obj.rawXY;xy];
                obj.dataLength(end+1) = newLength;             
            else
                fprintf(1,'ERROR: dismatch of in data dim: %d with MultiPro instance data dim: %d\n',newDim,obj.dataDim);
                fprintf(1,'Action Cancelled\n');
            end  
        end
        
        function pN = get.particleNum(obj)
            pN = length(obj.dataLength);
        end
        
        function tL = get.totalLength(obj)
            tL = sum(obj.dataLength);
        end
        
        function c = get.centrality(obj)
            c = obj.kMeansCentrality;
        end
        
        function tau = get.timeDelay(obj)
            if obj.param
                tau = obj.param.timeDelay;
            end
        end
        
        function k = get.k(obj)
            if obj.param
                k = obj.param.k;
            end
        end
        
        function d = get.dimension(obj)
            if obj.param
                d = obj.param.dimension;
            end
        end
        
        function ds = get.distanceScale(obj)
            if obj.param
                ds = obj.param.distanceScale;
            end
        end
        
        function data = getData(obj,num)
            [a,b] = obj.pNum2pRegion(num,1);
            data = obj.rawData(a:b,:);
        end
        
        function xy = getTrace(obj,num)
            [a,b] = obj.pNum2pRegion(num,1);
            xy = obj.rawXY(a:b,:);
        end
        
        function data = getSecData(obj,num)
            [a,b] = obj.pNum2pRegion(num,2);
            data = obj.secondaryData(a:b,:);
        end
        
        function data = getSecIndex(obj,num)
            [a,b] = obj.pNum2pRegion(num,2);
            data = obj.secondaryIndex(1,a:b);            
        end
        
        function process(obj)
            [~,obj.param,index] = ParamSetting(obj.particleNum);
            if index
                
                fprintf(1,'Process in %s method with D = %d for %s distance\n',...
                        obj.param.method,obj.param.dim,obj.param.distanceScale);
                obj.velocityCell = cell(obj.particleNum,1);
                obj.secondaryLength = zeros(obj.particleNum,1);
                obj.secondaryHeader = zeros(obj.particleNum,1);
                
                switch obj.param.method
                    case 'uni'
                        aFun = @(raw,tau,D)rcTimeDelaySet(raw,tau,D);
                    case 'msd'
                        aFun = @(raw,tau,D)vecs2MSD(raw,D);
                    case 'multi'
                        aFun = @(raw,tau,D)multiVar2CM(raw,tau,D);
                end
                
                for m = 1:1:obj.particleNum
                    % calculate local velocity
                    tmpRaw = obj.getData(m);
                    tmpXY = obj.getTrace(m);
                    tmpV = zeros(size(tmpXY,1),1);
                    tmpV(2:end) = bsxfun(@(x,y)(sum((x-y).*(x-y),2)).^0.5,tmpXY(2:end,:),tmpXY(1:(end-1),:));
                    obj.velocityCell{m} = tmpV;
                    % calculate local secondary data
                    [secData,locHeader] = aFun(tmpRaw,obj.param.timeDelay,obj.param.dim);
                    obj.secondaryData = [obj.secondaryData;secData];
                    obj.secondaryLength(m) = size(secData,1);
                    obj.secondaryHeader(m) = locHeader;
                end
                
                % process k-means
                [obj.secondaryIndex,...
                 obj.kMeansCentrality,~] = MultiPro.optKMeans(obj.secondaryData,...
                                                              obj.param.k,...
                                                              obj.param.distanceScale,...
                                                              obj.param.order,...
                                                              obj.param.optRepeat);
                
                % create local Result
                obj.pResult = cell(obj.particleNum,1);     
                for m = 1:1:obj.particleNum
                    obj.pResult{m} = NPMotionTest(obj.param.method,obj.getTrace(m),...
                                                  obj.getSecData(m),...
                                                  obj.getSecIndex(m),...
                                                  obj.secondaryHeader(m),...
                                                  obj.kMeansCentrality,...
                                                  obj.velocityCell{m},...
                                                  obj.param.timeDelay,...
                                                  obj.param.dim,...
                                                  obj.param.k);
                end
                
                disp('Process Done!');
            end
        end
        
        function reInit(obj)
            obj.velocityCell = cell(obj.particleNum,1);
            obj.secondaryLength = zeros(obj.particleNum,1);
            obj.secondaryHeader = zeros(obj.particleNum,1);
            obj.secondaryData = [];
            obj.secondaryIndex = [];
            obj.kMeansCentrality = [];
            obj.pResult = cell(obj.particleNum,1);   
        end
        
        function hFigure = show(obj)
            if isempty(obj.kMeansCentrality)
                return;
            end
            hFigure = figure;
            hHBox = uiextras.HBox('Parent',hFigure);
            hVBoxL = uiextras.VBox('Parent',hHBox);
            hVBoxR = uiextras.VBox('Parent',hHBox);
            hHBox.Widths = [-3,-1];
            for m = 1:1:obj.particleNum
                tmpH = axes('Parent',hVBoxL);
                obj.pResult{m}.plotTest(tmpH,obj.pResult{m}.velocity);
                title(strcat('Parent:',32,obj.particleIds{m}));
            end
            
            for m = 1:1:size(obj.kMeansCentrality,1)
                tmpH = axes('Parent',hVBoxR);
                obj.pResult{1}.plotSingleCentric(tmpH,m);
            end
        end
    end
    
    methods (Access = private)
        function [a,b] = pNum2pRegion(obj,num,level)
            if level == 1
                ref = obj.dataLength;
            else
                ref = obj.secondaryLength;
            end
            if num > obj.particleNum
                a = 0;
                b = 0;
                return;
            end
            if num == 1
                a = 1;
            else
                a = sum(ref(1:(num-1))) + 1;
            end
            b = ref(num) + a - 1;
        end       
    end
    
    methods (Static)
        function [indexTag,C,D] = optKMeans(raw,k,comd,p,optTime)
            disp('Optimization begin...');
            disp(strcat('Total trial: ',num2str(optTime)));
            [indexTag,C,D] = kMeans(raw,k,comd,p);
            if optTime > 1
                for m = 2:1:optTime
                    [I,c,d] = kMeans(raw,k,comd,p);
                    if(d<D)
                        indexTag = I;
                        C = c;
                        D = d;
                    end
                end
                disp(strcat('The optimized distance is: ',num2str(D)));
            end    
        end
    end
    
    
    
end

