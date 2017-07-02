classdef ParticleRandMerge < handle
    
    properties
    	mergeResult;
        mergeNum;
        stepRange;
        typeSpec;
    end
    
    properties (Access = private)
        particleData;
        particleSample;

        drawColor;

        trackLength;
        mergeTypeIndex;
        mergeMember;
    end
        
    methods
        function obj = ParticleRandMerge(ndp,cdp,adp,amp,mergeNum,stepRange)
            obj.particleData = {ndp,cdp,adp,amp};
            obj.stepRange = obj.stepRange;
            obj.mergeNum = mergeNum;
            if obj.mergeNum > min([ndp.particleNum,cdp.particleNum,adp.particleNum,amp.particleNum])
            	warning('merge number is too big for particle data!');
            end            
            obj.drawColor = lines(5);
            obj.mergeResult = [];
            obj.stepRange = stepRange;
            obj.typeSpec = 1:1:4;
        end

        function merge(obj,spec,varargin)
            if ~isempty(varargin)
                isPlot = varargin{1};
            else
                isPlot = true;
            end
        	% init param to merge
        	obj.trackLength = round(rand(obj.mergeNum,1) * range(obj.stepRange) + obj.stepRange(1));
        	obj.mergeResult = zeros(sum(obj.trackLength),3);
            if isempty(spec)
                obj.mergeTypeIndex = round(rand(obj.mergeNum,1) * (length(obj.typeSpec) - 1) + 1); 
            else
                obj.mergeTypeIndex = spec;
            end
            obj.mergeTypeIndex = obj.typeSpec(obj.mergeTypeIndex); %% 1 for ND | 2 for CD | 3 for AD | 4 for AM
            obj.mergeMember = zeros(obj.mergeNum,1);
        	obj.particleSample = {SampleContainer(1:1:obj.particleData{1}.particleNum,obj.particleData{1}.particleNum),...
                                  SampleContainer(1:1:obj.particleData{2}.particleNum,obj.particleData{2}.particleNum),...
                                  SampleContainer(1:1:obj.particleData{3}.particleNum,obj.particleData{3}.particleNum),...
                                  SampleContainer(1:1:obj.particleData{4}.particleNum,obj.particleData{4}.particleNum)};

            % init pos offset
        	lastPos = zeros(1,3);
            if isPlot
                member_feature = zeros(obj.mergeNum,3); 
            end
        	for m = 1:1:obj.mergeNum
        		[tmpTrace,index] = obj.getTraceFrom(obj.mergeTypeIndex(m),obj.trackLength(m));
                if isPlot
                    [~,~,member_feature(m,1),member_feature(m,2),member_feature(m,3)] = MSA(tmpTrace,length(tmpTrace),0);
                end
                obj.mergeMember(m) = index;
        		obj.mergeResult(obj.startFrom(m) - 1 + (1:1:obj.trackLength(m)),:) = tmpTrace + repmat(lastPos,[obj.trackLength(m),1]);
        		lastPos = obj.mergeResult(obj.startFrom(m) - 1 + obj.trackLength(m),:);
            end
            if isPlot
                c = lines;
                color_map = c([2,3,4,5],:);
                figure;
                scatter3(member_feature(:,1),member_feature(:,2),member_feature(:,3),...
                         30,color_map(obj.mergeTypeIndex,:),'filled');
                xlabel('Alpha');
                ylabel('D');
                zlabel('MSS');
                xlim([0,2]);
                ylim([0,max(member_feature(:,2))*1.2]);
                zlim([0,1]);
                box on;
            end
        end
        
        function simpleMerge(obj)
            obj.mergeTypeIndex = randsample(obj.typeSpec,obj.mergeNum,'true');
            obj.trackLength = zeros(obj.mergeNum,1);
            obj.mergeResult = [];
            mergeTraceIndex = cell(length(obj.typeSpec),1);
            obj.mergeMember = zeros(obj.mergeNum,1);
            for m = 1:1:length(obj.typeSpec)
                type = obj.typeSpec(m);
                mergeTraceIndex{m} = randsample(1:1:obj.particleData{type}.particleNum,sum(obj.mergeTypeIndex==type),'true');
            end
            lastPos = zeros(1,3);
            for m = 1:1:obj.mergeNum
                type = obj.mergeTypeIndex(m);
                traceIndex = mergeTraceIndex{obj.typeSpec==type}(1);
                mergeTraceIndex{obj.typeSpec==type}(1) = [];
                tmpTrace = obj.particleData{type}.getParticle(traceIndex);
                tmpTrace = tmpTrace(:,2:4);
                obj.mergeMember(m) = traceIndex;
                obj.trackLength(m) = length(tmpTrace) - 1;
                modified_trace = tmpTrace + repmat(lastPos,[length(tmpTrace),1]);
                modified_trace = modified_trace(2:end,:);
                lastPos = modified_trace(end,:);
                obj.mergeResult = [obj.mergeResult;modified_trace];
            end           
        end

        function plotMerge(obj,isSimple,specificity,varargin)
        	if isempty(obj.mergeResult)
                if isSimple
                    obj.simpleMerge();
                else
                    obj.merge(specificity);
                end
        	end

        	if isempty(varargin)
        		hf = figure;
        		set(hf,'KeyPressFcn',@(sender,eventArg)obj.onSpaceDown(sender,eventArg,isSimple));
                hA = axes;
        		plot(hA,obj.mergeResult(:,1),obj.mergeResult(:,2),'Color',obj.drawColor(1,:));
        		hold on;
            else
         		plot(varargin{1},obj.mergeResult(:,1),obj.mergeResult(:,2),'Color',obj.drawColor(1,:));
        		hold on;
                hA = varargin{1};
            end
            
            showTag = ones(4,1);
        	for m = 1:1:obj.mergeNum
                starter = obj.startFrom(m);
        		ender = starter + obj.trackLength(m) - 1;
                hA.NextPlot = 'add';
        		hs = scatter(hA,obj.mergeResult(starter:ender,1),obj.mergeResult(starter:ender,2),10,obj.drawColor(obj.mergeTypeIndex(m)+1,:),'filled');
                if showTag(obj.mergeTypeIndex(m))
                    set(hs,'DisplayName',obj.typeName(obj.mergeTypeIndex(m)));
                    showTag(obj.mergeTypeIndex(m)) = 0;
                else
                    set(get(get(hs,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');               
                end
                hA.NextPlot = 'replace';
            end
            legend(hA,'show');
        	hold off;
            title(hA,sprintf('Total length: %d',length(obj.mergeResult)));
        end
        
        function plotMean(obj,dim)
            figure;
            axes;
            hold on;
            for m = 1:1:obj.mergeNum
                tmp = obj.getResultAt(m);
                plot(mean(vecs2MSD(tmp(:,1:2),dim)),'DisplayName',strcat('Mean MSD of element:',32,num2str(m)));              
            end
            hold off;
        end
                
        function [index,result] = getResult(obj)
            result = obj.mergeResult;
            index = zeros(sum(obj.trackLength),1);
            for m = 1:1:obj.mergeNum
                index(obj.startFrom(m) - 1 + (1:1:obj.trackLength(m))) = obj.mergeTypeIndex(m);
        	end
        end
        
        function [pR,typeIndex,memberIndex] = getResultAt(obj,m)
            typeIndex = obj.mergeTypeIndex(m);
            memberIndex = obj.mergeMember(m);
            data = obj.particleData{typeIndex}.getParticle(memberIndex);
            pR = data(1:1:obj.trackLength(m),2:4);
        end
        
        function motionTest = toMotionTest(obj)
            analysisMethod = 'Simulated';
            xy = obj.mergeResult(:,1:2);
            resultData = xy;
            [indexTag,~] = obj.getResult();
            header = 1;
            centric = zeros(4,4);
            velocity = xy2vel(xy);
            tau = 0;
            D = 4;
            k = 4;
            motionTest = NPMotionTest(analysisMethod,xy,resultData,indexTag,header,...
                                      centric,velocity,tau,D,k);
        end
        
        function I = getResultIndex(obj)
            I = zeros(sum(obj.trackLength),1);
            counter = 1;
            for m = 1:1:obj.mergeNum
                L = obj.trackLength(m);
                I(counter:1:(counter + L - 1)) = ones(L,1) * obj.mergeTypeIndex(m);
                counter = counter + L;
            end
        end
    end

    methods (Access = private)
    	%% getTraceFrom: function description
    	function [trace,memberIndex] = getTraceFrom(obj,typeIndex,stepNum)
    		L = 0;
    		while L < stepNum
    			memberIndex = obj.particleSample{typeIndex}.next();
    			traceData = obj.particleData{typeIndex}.getParticle(memberIndex);
    			L = size(traceData,1);
    			if and(obj.particleSample{typeIndex}<=0,L<stepNum)
    				error('Cannot find situable trace data!');
    			end
    		end

    		trace = traceData(1:stepNum,2:4); %|frame|X|Y|Z|
    	end

    	function index = startFrom(obj,m)
    		if m == 1
    			index = 1;
    			return;
    		end
    		index = sum(obj.trackLength(1:(m-1))) + 1;
    	end

    	%% onSpaceDown: function description
    	function onSpaceDown(obj,sender,eventArg,varargin)
            if strcmp(eventArg.Key,'space')
                isSimple = varargin{1};
                if isSimple
                    obj.simpleMerge();
                else
                    obj.merge();
                end
                tmp = get(sender,'Children');
                obj.plotMerge(isSimple,tmp(end));
            end
        end
        
        function name = typeName(~,typeIndex)
            switch typeIndex
                case 1
                    name = 'Normal Diddsion';
                case 2
                    name = 'Confined Diffusion';
                case 3
                    name = 'Anomalous Diffusion';
                case 4
                    name = 'Direct Motion';
            end
        end
    	
    end
    
    methods (Static)
        function [res,mergePoint] = mergeTwo(a,b)
            [mergePoint,D] = size(a);
            L = mergePoint + size(b,1) - 1;
            res = zeros(L,D);
            res(1:1:mergePoint,:) = a;
            res((mergePoint+1):1:L,:) = b(2:end,:) + a(end,:);
        end
    end
    
end

