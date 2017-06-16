function stopPhotometryAcq
    % as of 8/16/16, this function works to reliably stop photometry acquisition and flush any
    % output data 
    global nidaq
    
    disp('trying to stop');
    nidaq.session.stop(); % Kills ~0.002 seconds after state matrix is done.
    disp('right before wait');
    wait(nidaq.session);
    disp('right after wait');
%     while ~nidaq.session.IsDone
%         pause(0.05);
%         disp('stopPhotometryAcq: Waiting for Stop');
%         nidaq.session.stop();
%     end
    disp(['nidaq IsDone status is ' num2str(nidaq.session.IsDone)]);
    nidaq.session.outputSingleScan(zeros(1, length(nidaq.channelsOn))); % make sure LEDs are turned off
