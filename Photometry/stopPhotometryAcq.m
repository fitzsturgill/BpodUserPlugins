function stopPhotometryAcq
    % as of 8/16/16, this function works to reliably stop photometry acquisition and flush any
    % output data 
    global nidaq
    
%     pause(0.05); % wait for hardware to stop, see error message below, I think this addresses the below error message:
%     %     Error using processNidaqData (line 15)
%     % Internal Error: The hardware did not report that it stopped before the timeout elapsed.
    nidaq.session.stop(); % Kills ~0.002 seconds after state matrix is done.
%     wait(nidaq.session);
    while nidaq.session.IsRunning
        pause(0.005);
        disp('waiting for session stop');
    end
    nidaq.session.outputSingleScan([0 0]); % make sure LEDs are turned off
    disp('flushing data');
    pause(0.005);
    nidaq.session.outputSingleScan([0 0]); % make sure LEDs are turned off 
    pause(0.005);
    nidaq.session.outputSingleScan([0 0]); % make sure LEDs are turned off 