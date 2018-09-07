function [res] = tagSegFunc(tags,dataMat,vision,func,varargin)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    if size(tags,1) == 1
        tags = tags';
    end
    resCell = {};
    L = length(tags);
    tags = [tags;inf*ones(vision,1)];
    bug = struct;
    bug.startAt = 1;
    bug.stageStepNum = 1;
    bug.curState = tags(1);
    for m = 1:1:L
        if isnan(bug.curState)
            furtherStage = sum(isnan(tags((m+1):(m+vision))));
        else
            furtherStage = sum(tags((m+1):(m+vision)) == bug.curState);
        end
        if furtherStage > 0
            % stay current stage
            bug.stageStepNum = bug.stageStepNum + 1;
        else
            % change stage
            tmpState = bug.curState;
            bug.curState = tags(m+1);
            if bug.stageStepNum > 1
                resCell{end+1} = [func(dataMat(bug.startAt:m,:),varargin{:}),...
                                  tmpState,bug.startAt,m];
            end
            bug.startAt = m+1;
            bug.stageStepNum = 1;         
        end
    end
    res = struct();
    res.resCell = resCell;
    res.length = L;
end

