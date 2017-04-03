function [lickTimes, lickTrials, nTrials] = bpGetLicks2(filtArg, zeroField)

    if nargin < 2
        zeroField = '';
    end


    trials = onlineFilterTrials_v2(filtArg{:});
    nTrials = length(trials);
    
    lickTimes = [];
    lickTrials = [];
    for i = 1:length(trials)
        trial = trials(i);
        if isfield(SessionData.RawEvents.Trial{trial}.Events, 'Port1In')
            theseLicks = SessionData.RawEvents.Trial{trial}.Events.Port1In;
            if isempty(zeroField)
                zeroTime = 0;
            else
                zeroTime = SessionData.RawEvents.Trial{trial}.States.(zeroField)(1,1); % always used first instance and start time stamp of zeroField for zeroing
            end
            theseLicks = theseLicks - zeroTime;
            lickTimes = [lickTimes theseLicks];
            lickTrials = [lickTrials zeros(1, length(theseLicks)) + i];

        else
            continue;
%             lickTimes(end + 1) = NaN; % else add a dummy lick at time 0 so that you make an empty line on the raster
%             lickTrials(end + 1) = i;
        end
    end