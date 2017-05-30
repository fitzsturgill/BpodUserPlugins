function updateLEDData(S)
    % updated 4/21/2017
    global nidaq

    % generate output data
    nidaq.dt = 1/nidaq.sample_rate;    
    t = (0:nidaq.dt:nidaq.duration - nidaq.dt)'; %last sample starts dt prior to t = duration
    nidaq.ao_data = [];
    ref = struct(...
        'phaseShift', [],...
        'freq', [],...
        'amp', []...
        );
    for ch = nidaq.channelsOn
        phaseShift = rand(1) * 2 * pi;
        freq = S.nidaq.(['LED' num2str(ch) '_f']);
        amp = S.GUI.(['LED' num2str(ch) '_amp']);
        channelData = (sin(2*pi*freq*t + phaseShift) + 1) /2 * S.GUI.LED1_amp;
        nidaq.ao_data = [nidaq.ao_data channelData];
        ref.phaseShift(end + 1) = phaseShift;
        ref.freq(end + 1) = freq;
        ref.amp(end + 1) = amp;
    end
    ref.channelsOn = nidaq.channelsOn;
    nidaq.ref = ref;
    nidaq.session.queueOutputData(nidaq.ao_data);