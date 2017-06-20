function S = preparePhotometryAcq(S)
    % Updated 4/20/2017 Now resets daq with every new trial
    % prepares NIDAQ session    
    % S = Bpod settings structure (contains updated information about LED
    % intensity, etc.)
    global nidaq BpodSystem
    
    daq.reset;
    
    % retrieve machine specific settings
    try
        addpath(genpath(fullfile(BpodSystem.BpodUserPath, 'Settings Files'))); % Settings path is assumed to be shielded by gitignore file
        phSettings = machineSpecific_Photometry;
        rmpath(genpath(fullfile(BpodSystem.BpodUserPath, 'Settings Files'))); % remove it just in case there would somehow be a name conflict        
    catch
        addpath(genpath(fullfile(BpodSystem.BpodPath, 'Settings Files'))); % Settings path is assumed to be shielded by gitignore file
        phSettings = machineSpecific_Photometry;
        rmpath(genpath(fullfile(BpodSystem.BpodPath, 'Settings Files'))); % remove it just in case there would somehow be a name conflict
    end
        
    
%     % defaults
%     phDefaults = {...
%         'TriggerConnection', 1;...
%         'LED1_f', 211;...
%         'LED2_f', 531;...
%         'duration', 6;...
%         'sample_rate', 6100;...
%         'ai_channelNames', {'ai0','ai1','ai2'};...
%         'ao_channelNames', {'ao0', 'ao1'};...
%         };
%     % defaults linked to Bpod parameter GUI
%     phGUIDefaults = {...
%         'LED1_amp', 1.5;...
%         'LED2_amp', 5;...
%         };
    phDefaults = phSettings.phDefaults;
    phGUIDefaults = phSettings.phGUIDefaults;

    
%     set defaults
    for counter = 1:size(phDefaults, 1)
        if ~isfield(S.nidaq, phDefaults{counter, 1});
            S.nidaq.(phDefaults{counter, 1}) = phDefaults{counter, 2};
        end
    end
    for counter = 1:size(phGUIDefaults, 1)
        if ~isfield(S.GUI, phGUIDefaults{counter, 1});
            S.GUI.(phGUIDefaults{counter, 1}) = phGUIDefaults{counter, 2};
        end
    end    
    
    
    maxDemodChannels = 2; % 
    
    % Define parameters for analog inputs and outputs
%     nidaq.LED1_f = S.nidaq.LED1_f;
%     nidaq.LED1_amp = S.GUI.LED1_amp;
%     nidaq.LED2_f = S.nidaq.LED2_f;
%     nidaq.LED2_amp = S.GUI.LED2_amp;    
%     nidaq.duration                 = S.nidaq.duration;
%     nidaq.sample_rate              = S.nidaq.sample_rate;

% 5/29/17, use syncPhotometrySettings instead of above commented lines
    syncPhotometrySettings;
    
%     nidaq.channelsOn = [];
%     if nidaq.LED1_amp > 0
%         nidaq.channelsOn(end + 1) = 1;
%     end
%     
%     if nidaq.LED2_amp > 0
%         nidaq.channelsOn(end + 1) = 2;
%     end
    
    % DO I NEED CHANNELNAMES NOW THAT i HAVE CHANNELSON? 5/29/17
    nidaq.ai_channelNames          = S.nidaq.ai_channelNames;       % 4 channels might make sense to have 2 supplementary channels for fast photodiodes measuring excitation light later
    nidaq.ai_data = [];
    % Define parameters for analog outputs.
    nidaq.ao_channelNames          = S.nidaq.ao_channelNames;
    nidaq.ao_data = [];
    nidaq.aiChannels = {};
    nidaq.aoChannels = {};
    
    %% fields for online analysis
    nidaq.online.currentDemodData = cell(1, maxDemodChannels);
    nidaq.online.currentXData = []; % x data starts from 0 (thus independent of protocol), add/subtract offset to redefine zero in protocol-specific funtions
    nidaq.online.trialXData = {};
    nidaq.online.trialDemodData = cell(1, maxDemodChannels);
    nidaq.online.decimationFactor = 1000;


    %% Set up session and channels
    nidaq.session = daq.createSession('ni');
    

    %% add inputs
    counter = 1;
    for ch = nidaq.channelsOn
        nidaq.aiChannels{counter} = addAnalogInputChannel(nidaq.session,S.nidaq.Device,ch - 1,'Voltage'); % - 1 because nidaq channels are zero based
        nidaq.aiChannels{counter}.TerminalConfig = 'SingleEnded';
        counter = counter + 1;
    end
    %% add outputs
    counter = 1;
    for ch = nidaq.channelsOn
        nidaq.aoChannels{counter} = nidaq.session.addAnalogOutputChannel(S.nidaq.Device,ch - 1, 'Voltage'); % - 1 because nidaq channels are zero based
        counter = counter + 1;
    end

    %% add trigger external trigger, if specified
    if S.nidaq.TriggerConnection
        addTriggerConnection(nidaq.session, 'external', [S.nidaq.Device '/' S.nidaq.TriggerSource], 'StartTrigger');
        nidaq.session.ExternalTriggerTimeout = 900; % something really long (15min), might be necessary during freely moving behavior when animal doesn't re-initiate trial for a while
    end
    
    %% Sampling rate and continuous updating (important for queue-ing ao data)
    nidaq.session.Rate = nidaq.sample_rate;
    nidaq.session.IsContinuous = true;
    
    %% create and cue data for output, add callback function
    updateLEDData(S); 
    % data available notify must be set after queueing data
    nidaq.session.NotifyWhenDataAvailableExceeds = nidaq.sample_rate; % fire event every second
    lh{1} = nidaq.session.addlistener('DataAvailable',@processNidaqData);
    
    
    
    
    
    
    %%
    nidaq.ai_data = [];
    nidaq.session.prepare(); %Saves 50ms on startup time, perhaps more for repeats.
    nidaq.session.startBackground(); % takes ~0.1 second to start and release control.