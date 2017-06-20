function stopPhotometryAcq
    % as of 8/16/16, this function works to reliably stop photometry acquisition and flush any
    % output data 
    global nidaq
    

    nidaq.session.stop(); % Kills ~0.002 seconds after state matrix is done.
    wait(nidaq.session);
    nidaq.session.outputSingleScan(zeros(1, length(nidaq.channelsOn))); % make sure LEDs are turned off
