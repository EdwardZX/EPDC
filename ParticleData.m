classdef ParticleData < handle
    
    properties
    end
    
    properties (Access = private)
        particleData;
    end
    
    properties (Dependent)
        particleNum;
        minLength;
    end
    
    methods
        function obj = ParticleData(raw)
            obj.particleData = raw;
        end
        
        function num = get.particleNum(obj)
            num = max(obj.particleData(:,1)) - min(obj.particleData(:,1)) + 1;
        end
        
        function mL = get.minLength(obj)
            L = obj.particleNum;
            mL = inf;
            for m = 1:1:L
                tmp = obj.getLength(m);
                if tmp < mL
                    mL = tmp;
                end           
            end
        end
        
        function data = getParticle(obj,varargin)
            if isempty(varargin)
                data = obj.particleData;
                return;
            end
            data = obj.particleData(obj.particleData(:,1)==varargin{1},2:5);
        end
        
        function result = getMSD(obj,tau,varargin)
            if tau > obj.minLength
                warning('MSD time Lag is bigger than the min particle trace length!');
            end
            if isempty(varargin)
                L = obj.particleNum;
                result = zeros(L,tau);
                for m = 1:1:L
                    tmp = obj.getParticle(m);
                    result(m,:) = msd(tmp(:,2:3),tau);
                end
                return;
            end
            tmp = obj.getParticle(varargin{1});
            result = msd(tmp(:,2:3),tau);
        end
        
        function h = plotMSD(obj,tau,varargin)
            if isempty(varargin)
                r = obj.getMSD(tau);
                r = [zeros(obj.particleNum,1),r];
                plot(0:1:tau,r(1,:),'Color',[0,0.45,0.75],'DisplayName','particle MSD');
                hold on;
                h = plot(0:1:tau,r(2:obj.particleNum,:)','Color',[0,0.45,0.75]);
                for m = 1:1:(obj.particleNum - 1)
                    set(get(get(h(m),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); 
                end
                return;
            end
            h = plot(obj.getMSD(tau)',varargin{1});   
            xlim([0,tau]);
        end
        
        function h = plotAveMSD(obj,tau)
            if tau > obj.minLength
                warning('MSD time Lag is bigger than the min particle trace length!');
            end
            r = obj.getMSD(tau);
            h = plot(mean(r,1),'r--','LineWidth',2,'DisplayName','average MSD');
        end
    end
    
    methods (Access = private)
        function L = getLength(obj,index)
            [L,~] = size(obj.getParticle(index));
        end
    end
    
end

