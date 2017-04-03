function updatePhotometryPlot(Op, startX)
% startX: time point in seconds from beginning of photometry
% acquisition to be defined as 0
    if nargin < 2
        startX = 0;
    end
    global BpodSystem nidaq
    
    Op = lower(Op);
    channelsOn = zeros(1,2);
    if nidaq.LED1_amp > 0
        channelsOn(1) = 1;
    end
    if nidaq.LED2_amp > 0
        channelsOn(2) = 1;
    end
    switch Op
        case 'init'
            scrsz = get(groot,'ScreenSize'); 

            BpodSystem.ProtocolFigures.NIDAQFig       = figure(...
                'Position', [25 scrsz(4)*2/3-100 scrsz(3)/2-50  scrsz(4)/3],'Name','NIDAQ plot','numbertitle','off');
            if all(channelsOn)
                BpodSystem.ProtocolFigures.NIDAQPanel1     = subplot(2,1,1);
                BpodSystem.ProtocolFigures.NIDAQPanel2     = subplot(2,1,2);
            elseif channelsOn(1)
                BpodSystem.ProtocolFigures.NIDAQPanel1     = subplot(1,1,1);
            else
                BpodSystem.ProtocolFigures.NIDAQPanel2     = subplot(1,1,1);
            end
     
        case 'update'

            xData = nidaq.online.currentXData + startX;
            if channelsOn(1)
                demod_ch1 = nidaq.online.currentDemodData{1};
                plot(BpodSystem.ProtocolFigures.NIDAQPanel1,xData, demod_ch1);
            end
            
            if channelsOn(2)
                demod_ch2 = nidaq.online.currentDemodData{2};
                plot(BpodSystem.ProtocolFigures.NIDAQPanel2,xData, demod_ch2);
            end

            zoomFactor = 5; % scale y axis +/- zoomFactor standard deviations from the mean


            if channelsOn(1)
                ylabel(BpodSystem.ProtocolFigures.NIDAQPanel1,{'Ch1'});
                m1 = mean(demod_ch1);
                s1 = std(demod_ch1);
                set(BpodSystem.ProtocolFigures.NIDAQPanel1, 'YLim', [m1 - s1*zoomFactor, m1 + s1*zoomFactor]);
            end

            if channelsOn(2)
                ylabel(BpodSystem.ProtocolFigures.NIDAQPanel2,{'Ch2'})
                m2 = mean(demod_ch2);
                s2 = std(demod_ch2);    
                set(BpodSystem.ProtocolFigures.NIDAQPanel2, 'YLim', [m2 - s2*zoomFactor, m2 + s2*zoomFactor]);
            end
            drawnow;
        %     legend(nidaq.ai_channels,'Location','East')
    end