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

        function merge(obj)
        	% init param to merge
        	obj.trackLength = round(rand(obj.mergeNum,1) * range(obj.stepRange) + obj.stepRange(1));
        	obj.mergeResult = zeros(sum(obj.trackLength),3);
            obj.mergeTypeIndex = round(rand(obj.mergeNum,1) * (length(obj.typeSpec) - 1) + 1);  %% 1 for ND | 2 for CD | 3 for AD | 4 for AM
            obj.mergeTypeIndex = obj.typeSpec(obj.mergeTypeIndex);
            obj.mergeMember = zeros(obj.mergeNum,1);
        	obj.particleSample = {SampleContainer(1:1:obj.particleData{1}.particleNum,obj.particleData{1}.particleNum),...
                                  SampleContainer(1:1:obj.particleData{2}.particleNum,obj.particleData{2}.particleNum),...
                                  SampleContainer(1:1:obj.particleData{3}.particleNum,obj.particleData{3}.particleNum),...
                                  SampleContainer(1:1:obj.particleData{4}.particleNum,obj.particleData{4}.particleNum)};

            % init pos offset
        	lastPos = zeros(1,3);

        	for m = 1:1:obj.mergeNum
        		[tmpTrace,index] = obj.getTraceFrom(obj.mergeTypeIndex(m),obj.trackLength(m));
                obj.mergeMember(m) = index;
        		obj.mergeResult(obj.startFrom(m) - 1 + (1:1:obj.trackLength(m)),:) = tmpTrace + repmat(lastPos,[obj.trackLength(m),1]);
        		lastPos = obj.mergeResult(obj.startFrom(m) - 1 + obj.trackLength(m),:);
        	end
        end

        function plotMerge(obj,varargin)
        	if isempty(obj.mergeResult)
        		obj.merge();
        	end

        	if isempty(varargin)
        		hf = figure;
        		set(hf,'KeyPressFcn',@(sender,eventArg)obj.onSpaceDown(sender,eventArg));
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
        		hs = scatter(hA,obj.mergeResult(starter:ender,1),obj.mergeResult(starter:ender,2),10,obj.drawColor(obj.mergeTypeIndex(m)+1,:),'filled');
                if showTag(obj.mergeTypeIndex(m))
                    set(hs,'DisplayName',obj.typeName(obj.mergeTypeIndex(m)));
                    showTag(obj.mergeTypeIndex(m)) = 0;
                else
                    set(get(get(hs,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');               
                end
            end
            legend('show');
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
    	function onSpaceDown(obj,sender,eventArg)
            if strcmp(eventArg.Key,'space')
                obj.merge();
                tmp = get(sender,'Children');
                obj.plotMerge(tmp(end));
            end
        end
        
        function name = typeName(obj,typeIndex)
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
    
end

