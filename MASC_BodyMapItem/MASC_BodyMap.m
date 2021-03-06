%% Embodied Emotion Survey Item - Body Map
%  updated to repeat for all trials
%
%  Instructions: "Mark on this body map where, if at all, you feel emotion
%  in your body right now"
%
%
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

function MASC_BodyMap(subid)

% Screen Set up
% override sync tests for now
Screen('Preference', 'SkipSyncTests', 1);
% Open up a window on the screen and clear it.
whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
textColor=white;
[w,theRect] = PsychImaging('OpenWindow', whichScreen, black);
% [w,theRect] = Screen(whichScreen,'OpenWindow',0);
Screen(w,'TextSize',35);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
line_color=[63 183 209 81];,line_width=4;
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
fname=sprintf('MASC_BodyMap_Dat_%d_%s',subid,datestr(now));
% datafilename = strcat(fname,'.txt'); % name of data file to write to
% datafilepointer = fopen(datafilename,'wt'); % open ASCII file for writing

%% text questions
start_instruct='On this laptop you will be asked to color on a body map where, if at all, you feel sensation or emotion in your body at different points of this experiment.\nSometimes you may be asked where you think SOMEONE ELSE felt sensation or emotion in their body.\nPlease pay attention to the instructions on each trial.\n\nTo make your rating, hold and click on the body map with the mouse. When you are finished, hit space.\n\nWhen you are ready to start the task training, your experimenter will press SPACE on this computer.';
base_instruct='With the mouse, mark on the body map where, if at all, ';
end_instruct='\n \nClick to start. Hit space to finish.';

baseline=sprintf('%s YOU feel sensation or emotion RIGHT NOW.%s',base_instruct,end_instruct);
vid_other=sprintf('%s you think the PERSON IN THE VIDEO felt sensation or emotion while telling their story.%s',base_instruct,end_instruct);
vid_self=sprintf('%s YOU felt sensation or emotion while you watched the video.%s',base_instruct,end_instruct);
sharing=sprintf('%s YOU felt sensation or emotion while you were telling your story.%s',base_instruct,end_instruct);
% no randomization -- order list
Q_Order_List={baseline;baseline;baseline;vid_other;vid_self;baseline;vid_other;vid_self;baseline;vid_other;vid_self;baseline;vid_other;vid_self;baseline;baseline;baseline;baseline;baseline;sharing;baseline;baseline;sharing;baseline};

endexper='Thank you. Your responses have been recorded.';

%%%%%%%%%%%%%%%%%% TASK %%%%%%%%%%%%%%%%%%
try
    DrawFormattedText(w,start_instruct,'center','center',textColor,48);
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
                        Screen(w,'DrawLine',line_color,thePoints(numPoints-1,1),thePoints(numPoints-1,2),thePoints(numPoints,1),thePoints(numPoints,2),line_width);
                    else
                        [theX,theY] = GetMouse(w);
                        Screen(w,'DrawLine',line_color,theX,theY,theX,theY,line_width);
                        % ...we ask Flip to not clear the framebuffer after flipping:
                        newPt=0;
                    end
                    Screen('Flip', w, 0, 1);
                    theX = x; theY = y;
                end
            end
        end
        
        %save thePoints
        MASC_Body{trial}.bmap_raw=thePoints;
        MASC_Body{trial}.bmap_x_y=[thePoints(:,1),theRect(RectBottom)-thePoints(:,2)];
        MASC_Body{trial}.time_on_task = GetSecs - startTime;
        MASC_Body{trial}.Question=Q_Order_List{trial};
        MASC_Body{trial}.TimeStamp=datestr(now);
        
        
        save MASC_Body MASC_Body
        save(fname,'MASC_Body');
        
        % clear screen for next trial
        WaitSecs(0.5);
        Screen('Flip', w);
      
        DrawFormattedText(w,'Hit SPACE when ready for the next trial.','center','center',textColor);
        Screen('Flip',w);
        while 1
            [~,~,keyCode2] = KbCheck;
            if keyCode2(KbName('space'))==1
                break
            end
        end
    end
catch
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
    save(fname,'MASC_Body');
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