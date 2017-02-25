classdef SampleContainer < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        randArray;
        pointer;
        maxNum;
    end
    
    methods
        function obj = SampleContainer(sample,num)
            obj.randArray = randsample(sample,num);
            obj.pointer = 0;
            obj.maxNum = num;
        end
        
        function num = next(obj)
            obj.pointer = obj.pointer + 1;
            if obj.pointer > obj.maxNum
                num = nan;
            else
                num = obj.randArray(obj.pointer);
            end      
        end

        %% remain: return the sample index avaliable remaining
        function num = remain(obj)
        	num = obj.maxNum - obj.pointer;
        end

        %% refresh: function description
        function refresh(obj)
        	obj.pointer = 0;
        end
        
        
    end
    
end

