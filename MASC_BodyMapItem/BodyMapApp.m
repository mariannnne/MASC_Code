%% Embodied Emotion Survey Item - Body Map
%  app asks user to indicate on the body map, where, if at all, they feel
%  sensation in their body in response to some image, event, or emotion.
%
%  if you get an error try adding path to psychtoolbox
%  addpath(genpath('/Applications/Psychtoolbox'))
%
%  this is the matlab version that will be made into a java app for
%  medialab
%
%  uses psychtoolbox
%
%  Records: coloring on bodymap, time on task & saved a s a .mat file
%
%  by marianne, 2018

function BodyMapApp(subid)

% Screen Set up
% override sync tests for now
Screen('Preference', 'SkipSyncTests', 1);
% Open up a window on the screen and clear it.
whichScreen = max(Screen('Screens'));
[w,theRect] = Screen(whichScreen,'OpenWindow',0);
Screen(w,'TextSize',35);
line_color=[63 183 209 81];
% Get the size of the on screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', w);
% Set priority for script execution to realtime priority:
priorityLevel=MaxPriority(w);
Priority(priorityLevel);

% Timing Set Up
WaitSecs(0.1);
GetSecs;

% Suppress output in matlab window
ListenChar(2); 

% Load bodymap image data
bmdata=imread('bodymap.jpg');

% Sub info - can you pass sub info in from medialab?
fname=sprintf('BodyMapDat_%d_%s',subid,datestr(now));
% datafilename = strcat(fname,'.txt'); % name of data file to write to
% datafilepointer = fopen(datafilename,'wt'); % open ASCII file for writing

%% text 
start_instruct='On this laptop you will be asked to color on a body map where, if at all, you feel sensation or emotion at different points of this experiment. \n \nTo do this, hold and click on the body map with the mouse. \nThen hit space when you are finished. \n \nWhen you are ready to start the task training, your experimenter should press any key on this computer.';
base_instruct='With the mouse, mark on the body map where, if at all, ';
end_instruct='\n \nClick to start. Hit space to finish.';

baseline=sprintf('%s you feel sensation or emotion RIGHT NOW.%s',base_instruct,end_instruct);
vid_other=sprintf('%s you think the PERSON IN THE VIDEO felt sensation or emotion while telling their story.%s',base_instruct,end_instruct);
vid_self=sprintf('%s you felt sensation or emotion while you watched the video.%s',base_instruct,end_instruct);
sharing=sprintf('%s you felt sensation or emotion while you were telling your story.%s',base_instruct,end_instruct);
% no randomization -- order list
Q_Order_List={baseline;baseline;baseline;vid_other;vid_self;baseline;vid_other;vid_self;baseline;vid_other;vid_self;baseline;vid_other;vid_self;baseline;baseline;baseline;baseline;baseline;sharing;baseline;baseline;sharing;baseline};

endexper='Thank you. Your Response has been recorded.';
%%%%%%%%%%%%%%%%%% TASK %%%%%%%%%%%%%%%%%%
try
    DrawFormattedText(w,start_instruct,'center','center',textColor,50);
    Screen('Flip',w)
    while 1
        [~,startTime,keyCode] = KbCheck;
        if keyCode(KbName('space'))==1
            break
        end
    end
    
    for trial=1:length(Q_Order_List)
    % display bodymap
    bmtex=Screen('MakeTexture', w, bmdata);
    Screen('DrawTextures', w, bmtex);
    
    % mouseaction
    % Move the cursor to the center of the screen
    theX = round(theRect(RectRight) / 2);
    theY = round(theRect(RectBottom) / 2);
    SetMouse(theX,theY,whichScreen);
    
    % instructions
    DrawFormattedText(w,Q_Order_List{trial},100,100,255,15);
    starttime=Screen('Flip', w, 0, 1);

    % click to start
    while (1)
        [~,~,buttons] = GetMouse(w);
        if buttons(1)
            break;
        end
    end

    % Loop and track the mouse, drawing the contour
    [theX,theY] = GetMouse(w);
    thePoints = [theX theY];
    Screen(w,'DrawLine',line_color,theX,theY,theX,theY); 
    % Set the 'dontclear' flag of Flip to 1 to prevent erasing the
    % frame-buffer:
    Screen('Flip', w, 0, 1);
    newPt=0;
    while (1)
        [~,startTime,keyCode] = KbCheck;
        if keyCode(KbName('space'))==1
            break
        else keepDraw=1;
        end

        while keepDraw
            [x,y,buttons] = GetMouse(w);
            if ~buttons(1)
                newPt=5;
                break;
            else
                thePoints = [thePoints ; x y]; %#ok<AGROW>
                [numPoints, ~]=size(thePoints);
                % Only draw the most recent line segment
                if ~newPt
                    Screen(w,'DrawLine',line_color,thePoints(numPoints-1,1),thePoints(numPoints-1,2),thePoints(numPoints,1),thePoints(numPoints,2));
                else
                    [theX,theY] = GetMouse(w);
                    Screen(w,'DrawLine',line_color,theX,theY,theX,theY);
                    % ...we ask Flip to not clear the framebuffer after flipping:
                    newPt=0;
                end
                Screen('Flip', w, 0, 1);
                theX = x; theY = y;
            end
        end
    end
    
    %save thePoints
    bmap_raw=thePoints;
    bmap_x_y=[thePoints(:,1),theRect(RectBottom)-thePoints(:,2)];
    time_on_task = GetSecs - startTime;
    
    %Screen('Flip', w);
    save IAPSbmap bmap_raw bmap_x_y
    save(fname,'time_on_task','bmap_raw','bmap_x_y');
    
    end
    
catch
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
    save(fname,'time_on_task','bmap_raw','bmap_x_y');
end
%%%%%%%%%%%%%%%%%%%%%
%% END SCREEN
%%%%%%%%%%%%%%%%%%%%%
DrawFormattedText(w,endexper,'center',800,255);
Screen('Flip',w);
WaitSecs(1);

%%%%%%%%%%%%%%%%%%%%%
%% CLEAN UP
%%%%%%%%%%%%%%%%%%%%%
Screen('CloseAll');
Priority(0);
sca;
end