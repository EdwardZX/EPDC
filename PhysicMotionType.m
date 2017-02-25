classdef PhysicMotionType < uint8
    enumeration
        Normal(1)
        Confined(2)
        Anomalous(3)
        Directed(4)
    end
    
    methods (Static)
        function name = toString(type)
            switch type
                case PhysicMotionType.Normal
                    name = 'Normal Diffusion';
                case PhysicMotionType.Confined
                    name = 'Confined Diffusion';
                case PhysicMotionType.Anomalous
                    name = 'Anomalous Diffusion';
                case PhysicMotionType.Directed
                    name = 'Directed Diffusion';
            end
        end
    end
end

