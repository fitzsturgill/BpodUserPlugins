function phDemodOnline(currentTrial)
    global BpodSystem nidaq

    decimationFactor = nidaq.online.decimationFactor;
    lowCutoff = 15;
    LED1_f = nidaq.LED1_f;
    LED2_f = nidaq.LED2_f;
    
    for ch = nidaq.channelsOn
        nidaq.online.currentDemodData{ch} = phDemod(nidaq.ai_data(:,ch), nidaq.ao_data(:,ch), nidaq.sample_rate, LED1_f, lowCutoff);
        nidaq.online.trialDemodData{currentTrial, ch} = nidaq.online.currentDemodData{:, ch};
    end
%         nidaq.online.currentDemodData{1} = NaN(size(nidaq.ai_data(:,1)));
%     end
%     if nidaq.LED2_amp > 0    
%         nidaq.online.currentDemodData{2} = phDemod(nidaq.ai_data(:,2), nidaq.ao_data(:,2), nidaq.sample_rate, LED2_f, lowCutoff);    
%     else
%         nidaq.online.currentDemodData{2} = NaN(size(nidaq.ai_data(:,2)));
%     end
    %% generate x data, scale from 0 initially (you can add/subtract offsets to x data within downstream funtions)
    dT = 1/nidaq.sample_rate;
    nidaq.online.currentXData = 0:dT:nidaq.duration - dT;
    nidaq.online.currentXData = nidaq.online.currentXData(:); % make column vector

    
  %% pad or truncate if acquisition stopped short or long, but as of 8/15/16 this functionality is redundant- see processNidaqData
    samplesShort = length(nidaq.online.currentXData) - length(nidaq.online.trialDemodData{currentTrial, 1});
    if samplesShort > 0 % i.e. not 0
        nidaq.online.trialDemodData{currentTrial, 1} = [nidaq.online.trialDemodData{currentTrial, 1}; zeros(samplesShort, 1)];
        nidaq.online.trialDemodData{currentTrial, 2} = [nidaq.online.trialDemodData{currentTrial, 2}; zeros(samplesShort, 1)];        
    elseif samplesShort < 0
        nidaq.online.trialDemodData{currentTrial, 1} = nidaq.online.trialDemodData{currentTrial, 1}(1:length(nidaq.online.currentXData));
        nidaq.online.trialDemodData{currentTrial, 2} = nidaq.online.trialDemodData{currentTrial, 2}(1:length(nidaq.online.currentXData));
    end      
    
    nidaq.online.currentDemodData{1} = nidaq.online.trialDemodData{currentTrial, 1};
    nidaq.online.currentDemodData{2} = nidaq.online.trialDemodData{currentTrial, 2};
    %% downsample and save trial data
    nidaq.online.trialXData = decimate(nidaq.online.currentXData, decimationFactor);
    nidaq.online.trialDemodData{currentTrial, 1} = decimate(nidaq.online.currentDemodData{1}, decimationFactor);
    nidaq.online.trialDemodData{currentTrial, 2} = decimate(nidaq.online.currentDemodData{2}, decimationFactor);    
    

