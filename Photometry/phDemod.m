function demod = phDemod(rawData, refData, sampleRate, modRate, lowCutoff)
% DEMODULATE AM-MODULATED INPUT IN QUADRATURE GIVEN A REFERENCE
% tBaseline-  baseline period, in seconds
% lowCutoff corner frequency for 5-pole butterworth filter (lowpass),
% default = [], i.e. no filtering is performed

    if nargin < 5
        lowCutoff = []; 
    end
    

    
    
%     if nargin < 5
%         tBaseline = []; % if empty, normalize (zscore) by entire range
%     end
    
    if size(rawData, 2) ~= 1 ||size(refData, 2) ~= 1
        disp('*** Error in phDemod, refData and rawData must be column vectors ***');
        demod = [];
        return
    end
%     rawData(:,1) = rawData; % ensure column vectors
%     refData(:,1) = refData; 

    
    if ~isstructure(refData)
        nSamples = length(rawData);
        refData = refData(1:nSamples,1); % shorten refData to same size as rawData    
        refData = refData - mean(refData); % *** get rid of DC offset!!!!

        % generate 90degree shifted copy of refData
        samplesPerPeriod = 1/modRate / (1/sampleRate);
        quarterPeriod = round(samplesPerPeriod / 4); % ideally you shouldn't have to round, i.e. mod frequencies should be close to factors of sample freq
        refData90 = circshift(refData, [1 quarterPeriod]);

        processedData_0 = rawData .* refData;
        processedData_90 = rawData .* refData90;
    else
        phaseShift = rand(1) * 2 * pi;
        freq = S.nidaq.(['LED' num2str(ch) '_f']);
        amp = S.GUI.(['LED' num2str(ch) '_amp']);
        channelData = (sin(2*pi*freq*t + phaseShift) + 1) /2 * S.GUI.LED1_amp;
        nidaq.ao_data = [nidaq.ao_data channelData];
        ref.phaseShift(end + 1) = phaseShift;
        ref.freq(end + 1) = freq;
        ref.amp(end + 1) = amp;
    end
    %% try filtering first
    % note-   5 pole Butterworth filter in Matlab used in Frohlich and McCormick  
     % Create butterworth filter
    lowCutoff = lowCutoff/sampleRate * 2; % multiply by 2 to convert to rad/sample- see butter documentation
    % for a cutoff freq of 300Hz and sample rate of 1000Hz, cutoff
    % corresponds to 0.6pi rad/sample    300/1000 * 2 = 0.6    
    [b, a] = butter(5, lowCutoff, 'low');   % double order of butterworth filter since I'm not using filtfilt
    pad = 1;
    if pad
%         paddedData = fliplr(demodData(1:sampleRate, 1)); % pad with 1s of reflected data
%         paddedData = demodData(randperm(sampleRate), 1); % pad with 1s of randomized data (should still contain DC trend)
        paddedData_0 = processedData_0(1:sampleRate, 1); % AGV sez: pad with 1s of data, should be in phase as period should be an integer factor of 1 second
        paddedData_90 = processedData_90(1:sampleRate, 1); % AGV sez: pad with 1s of data, should be in phase as period should be an integer factor of 1 second        
        % HOWEVER- an additional problem is that there is a hardware onset
        % transient when the LED turns on
        
        %% for online analysis just use filt for speed (not filtfilt)
        demodDataFilt_0 = filtfilt(b,a,[paddedData_0; processedData_0]);
        demodDataFilt_90 = filtfilt(b,a,[paddedData_90; processedData_90]);        
        demod_0 = demodDataFilt_0(length(paddedData_0) + 1:end, 1);
        demod_90 = demodDataFilt_90(length(paddedData_90)+1:end, 1);        
    else
%         demod_0 = filtfilt(b, a, demodData_0);
    end
    
    
    
    demod = (demod_0 .^2 + demod_90.^2) .^(1/2); % quadrature decoding




    
    % correct for amplitude of reference 
    
    % Vsig = Vsig*Vref/2 + Vsig*Vref/2 * Cos(2*Fmod * time)
    % you filter out the second term
    % multiply by two and divide by Vref to get Vsig
    try % why am I demodulating both channels by default???  Note  3/28/17
        modAmp = calcSinusoidAmp(refData);
    catch
        modAmp = 1;
    end
    demod = demod * 2 / modAmp;
%     fig = ensureFigure('test', 1);
%     plot(demodDataFilt);