function stopPhotometryAcq
    % as of 8/16/16, this function works to reliably stop photometry acquisition and flush any
    % output data 
    global nidaq
    
  
    if size(nidaq.ai_data, 1) < nidaq.duration * nidaq.sample_rate
        pause(0.05); % wait for processNidaqData to finish executing
    end
    nidaq.session.stop(); % Kills ~0.002 seconds after state matrix is done.
    wait(nidaq.session);
    nidaq.session.outputSingleScan(zeros(1, length(nidaq.channelsOn))); % make sure LEDs are turned off
