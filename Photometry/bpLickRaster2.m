function [ax, lh] = bpLickRaster2(SessionData, filtArg, zeroField, figName, ax)
        % create lickRaster for an individual session
        % optional arguments: if you want to use a preexisting axis,
        % then pass '' to figName and pass the axes handle
        
        % zerofield: string, e.g. 'DeliverStimulus'
    if nargin < 4
        figName = 'lickRaster';
    end
    
    if ~isempty(figName)
        fig = ensureFigure(figName, 1);
    else
        fig = gcf;
        clf;
    end

    
    if nargin < 5 %make a new axes unless one is provided
        ax=axes(...
        'Parent', fig,...
        'YDir', 'reverse'...
        );
    else
        axes(ax); %bring it to front and make sure that YDir is reversed
        set(ax, 'YDir', 'reverse');
    end


    [lickTimes, lickTrials, nLickTrials] = bpGetLicks2(filtArg, zeroField);
        
    lh = linecustommarker(lickTimes, lickTrials, [], [], ax);
    % make sure that yaxis spans total number of trials so that in the absence of licks the number of lickless trials is indicated    
    try
        set(ax, 'YLim', [0, max(nLickTrials, 1)]);
    catch
        disp('wtf');
    end
        

    
    
    
    
    