function syncPhotometrySettings    
%     function attempts to sync nidaq settings (part of
%     BpodSystem.Settings) with nidaq structure (containing nidaq session)
%     Note conventions below (somewhat historical):
    % convention is to have GUI-linked nidaq settings stored as
    % S.GUI.nidaqSetting and non-GUI-linked nidaq settings stored as
    % S.nidaq.nidaqSetting
    % function first attempts to find a GUI-linked version setting to sync, then
    % tries non-GUI-linked setting
    global nidaq BpodSystem
    S = BpodSystem.ProtocolSettings;   
    
    % these fields will either be specified in 
    syncFields = {'LED1_f', 'LED2_f', 'duration', 'sample_rate', 'LED1_amp', 'LED2_amp'};
    
    
    
    for counter = 1:length(syncFields)        
        sf = syncfields{counter};
        
        try
            nidaq.(sf) = S.GUI.(sf);
        catch
            try
                nidaq.(sf) = S.nidaq.(sf);
            catch
            end
        end
    end
            
    
    