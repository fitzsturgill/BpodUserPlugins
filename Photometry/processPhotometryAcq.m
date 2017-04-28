function processPhotometryAcq(currentTrial)
    global BpodSystem nidaq
    
%     wait(nidaq.session);
%     wait('nidaq.session');
%     while ~nidaq.session.IsDone
%         pause(0.05);
%     end

%     pause(0.1); 
%     nidaq.session.stop() % Kills ~0.002 seconds after state matrix is done.
%     wait(nidaq.session) % Trying to wait until session is done - did we record the full session?
    
    % ensure outputs reset to zerof
%     nidaq.session.outputSingleScan(zeros(1,length(nidaq.aoChannels)));

    %% Save data in BpodSystem format.   
    BpodSystem.Data.NidaqData{currentTrial, ch} = nidaq.ai_data; %input data
    BpodSystem.Data.NidaqData{currentTrial, 2} = nidaq.ref; % output data
    
    if isempty(nidaq.ai_data)
        disp(num2str(toc));
        error('WTF');
    else
        disp(num2str(toc));
    end
    
    