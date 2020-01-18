%%%% intentional binding, baseline tone
%%% written by Noham Wolpe, March 2012 %%%

%%% please cite:
%%% N Wolpe, P Haggard, HR Siebner, JB Rowe, 
%%% Cue integration and the perception of action in intentional binding
%%% Experimental brain research 229 (3), 467-474

%% setting up initial parameters
clear all;

ScreenSizeInPixels=[];
% ScreenSizeInPixels=[0 0 800 800];
colourbackground=255;


%% subjects details
commandwindow;
subject=input('Please enter subject number  ', 's');
blocknumber=input('Please enter block number  ', 's');
filename=[blocknumber, 'baselineTone'];

if blocknumber(1)=='p'
    numtrials=10;
else numtrials=20;
end

% initializing PTB screen
Screen('Preference', 'VisualDebuglevel', 0);
[won, rect_window]=Screen('OpenWindow',0, colourbackground, ScreenSizeInPixels);
flipInterval=Screen('GetFlipInterval', won);
HideCursor;

% initializing text config
Screen('TextSize',won,24);
Screen('TextFont',won,'Arial');
Screen('TextColor',won);

% setting up position for message
window_x=rect_window(3);
window_y=rect_window(4);
rectmessage=[window_x/2-100, window_y/2+50, window_x/2+100, window_y/2+100];

% setting up conditions matrix
numconditions=1; %:2; % condition 1: beep low, 2: beep high
stimulipercondition=numtrials/max(size(numconditions));
% conditions=repmat(numconditions,1,stimulipercondition);
% conditions=Shuffle(Shuffle(conditions));

% random interval between 1.5 to 2.5 secs between event judged and hand stopping
randInterval=RandLim(numtrials,1.5,2.5);
actioneffectInterval=0.25;

% setting up a starting position of the hand according to starting theta
% angle
startingTheta=RandLim(numtrials, 0, 2*pi);

% each cycle should be period(=2.560)/flipinterval
T=2.56;
numUnits=T/flipInterval;
% circle centre coordinates are (a,b) (255,255), r=17
centre=[rect_window(3)/2, rect_window(4)/2]; % (a,b) = (255, 255)
r=20; % radius size in pixels
handWidth = 2.5;

% load clock image
clock=imread('clock3.png');
clockTexture=Screen('MakeTexture', won, clock);
clockSize=110;
rect_clock=[rect_window(3)/2-clockSize/2, rect_window(4)/2-clockSize/2, ...
    rect_window(3)/2+clockSize/2, rect_window(4)/2+clockSize/2];


% intervals for random tone being played
intervals = RandLim([numtrials, 1], 2.5, 6);

% generate beeps and noise
% [noise, beep_low, beep_im, beep_loud] = NoiseToneGen;


%% trial starts
k=1;

while k<=numtrials
    
    priorityLevel=MaxPriority(won, 'FlushEvents', 'KbCheck');
    Priority=PriorityLevel;
    
    
    DrawFormattedText(won, 'Get ready to begin the next trial...', 'center', 'center');
    %     (rectmessage(1)+rectmessage(3))/2, (rectmessage(2)+rectmessage(4))/2);
    Screen(won,'Flip');
    WaitSecs(1);
    
    
    % initializing value for the different warnings
    warn=0;
    theta=startingTheta(k);
    keyIsDown=0;
    t0=GetSecs;
    press=0;
    % pressSwitch=0;
    beepSwitch=0;
    flag1=0; % for initial button press
    flag2=0; % for interval to pass after button press
%     play(noise);
    while (~flag1 || ~flag2)
        x=centre(1)+r*cos(theta);
        y=centre(2)+r*sin(theta);
        Screen('DrawTexture', won, clockTexture, [], rect_clock);
        Screen('DrawLine', won, 0, centre(1), centre(2), x, y, handWidth);
        Screen(won,'Flip');
        %     [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        if  GetSecs > t0+intervals(k) % flagging for first interval to pass for beep
            if conditions(k)==1
                play(beep_low);
            elseif conditions(k)==2
                play(beep_im);
            elseif conditions(k)==3
                play(beep_high);
            end
            flag1=1;
            %         RT1=GetSecs-t0;
            beepSwitch=1;
            thetaEvent=theta;
            t0=GetSecs;
        elseif (beepSwitch==1) && (t0+randInterval(k)<GetSecs) % additional random inteval to wait after event
            flag2=1;
            Screen('DrawTexture', won, clockTexture, [], rect_clock);
            Screen('DrawLine', won, 0, centre(1), centre(2), x, y, handWidth);
            Screen(won,'Flip', 0, 1);
        else theta = theta+2*pi*1/numUnits;
        end
    end
    
%     stop(noise);
    
    % transform thetas to msec
    % when theta equals zero it points at 15, 2pi=60
    factor=(mod(thetaEvent, (2*pi)))/(2*pi);
    clockNumberEvent=15+factor*60;
    if clockNumberEvent>60
        clockNumberEvent=clockNumberEvent-60;
    end
    startingPosition=15+60*startingTheta(k)/(2*pi);
    
    % number of periods completed
    periodsCompleted=thetaEvent/(2*pi);
    
    %% response
    t0=GetSecs;
    response=Ask(won,'Enter judged clock time  ',[],[],'GetChar',rectmessage,'center', 24);
    RT2=GetSecs-t0;
    
    estimate=str2double(response);
    % if subjects enter 99, it means they didn't hear a tone
    if estimate==99
        error=NaN;
    else error=estimate-clockNumberPressed;
    end
    
    if error>45
        error=error-60;
    elseif error<-45
        error = error+60;
    end
    
    % warning if taking too long
    
    if RT2>10
        warn=2;
        DrawFormattedText(won, 'Please try to enter the time a bit faster', 'center', 'center');
        Screen(won,'Flip');
        WaitSecs(2);
    end
    
    
    Results(k,1)=clockNumberEvent;
    Results(k,2)=estimate;
    Results(k,3)=intervals(k);
    Results(k,4)=RT2;
    Results(k,5)=randInterval(k); % time to wait after event
    Results(k,6)=startingTheta(k);
    Results(k,7)=startingPosition;
    Results(k,8)=thetaEvent;
    Results(k,9)=periodsCompleted;
    Results(k,10)=conditions(k);
    Results(k,11)=warn;
    Results(k,12)=error;
    
    
    Priority=0;
    clc;
    k=k+1;

end

Screen('CloseAll');

commandwindow;
clc;

%% creating data files %%
warning off MATLAB:xlswrite:AddSheet;
status1=xlswrite(subject, Results, filename);
if (status1==1)
     disp('creating dat file was successfully completed')
else disp('!!!!!error occurred in creating dat file!!!!!!')
end