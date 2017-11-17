%%%% ib
%%% written by Noham Wolpe, March 2012 %%%

%% setting up initial parameters
clear all;

ScreenSizeInPixels=[];
% ScreenSizeInPixels=[0 0 1200 800];
colourbackground=255;


%% subjects details
commandwindow;
subject=input('Please enter subject number  ', 's');
blocknumber=input('Please enter block number  ', 's');
% filename=[blocknumber, 'operantTone'];
filename=[blocknumber, 'operantAction'];

if blocknumber(1)=='p'
    numtrials=12;
else numtrials=30;
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
numconditions=1:3;
stimulipercondition=numtrials/length(numconditions);
% conditions=[];
% for i=1:stimulipercondition
%     conditions=[conditions, randperm(max(numconditions))];
% end

conditions=repmat(numconditions,1,stimulipercondition);
conditions=Shuffle(Shuffle(conditions));

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
r=20;
handWidth = 2.5;

% load clock image
clock=imread('clock3.png');
clockTexture=Screen('MakeTexture', won, clock);
clockSize=100;
rect_clock=[rect_window(3)/2-clockSize/2, rect_window(4)/2-clockSize/2, ...
    rect_window(3)/2+clockSize/2, rect_window(4)/2+clockSize/2];

% generate beeps and noise
% [noise, beep_low, beep_im, beep_loud] = NoiseToneGen(subject);


%% trial starts
k=1;

while k<=numtrials
    
    priorityLevel=MaxPriority(won, 'DrawLine', 'Flip', 'FlushEvents', 'KbCheck');
    Priority=priorityLevel;
    
    
    if k==1
        DrawFormattedText(won, 'Please press the button whenever you like to trigger the beep \n \n and then tell me when you pressed the button \n \n \n Press any key to start', 'center', 'center');
        Screen(won,'Flip');
        KbWait;
    end
    
    
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
    pressSwitch=0;
    beepSwitch=0;
    flag1=0; % for initial button press
    flag2=0; % for interval to pass after button press
    
%     play(noise);
    
    while (~flag1 || ~flag2)
        x=centre(1)+r*cos(theta);
        y=centre(2)+r*sin(theta);
        Screen('DrawTexture', won, clockTexture, []);%, rect_clock);
        Screen('DrawLine', won, 0, centre(1), centre(2), x, y, 3);
        Screen(won,'Flip');
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        if keyIsDown && pressSwitch==0 % additional flagging of button press
            flag1=1;
            RT1=GetSecs-t0;
            pressSwitch=1;
            keypressed=find(keyCode);
            thetaPressed=theta;
            t0=GetSecs;
        elseif (pressSwitch==1) && beepSwitch==0 && (t0+actioneffectInterval<GetSecs)
            beepSwitch=1;
            Beeper(1000, [], 0.1);
%             if conditions(k)==1
%                 play(beep_low);
%             elseif conditions(k)==2
%                 play(beep_im);
%             elseif conditions(k)==3
%                 play(beep_loud);
%             end
        elseif (pressSwitch==1) && (t0+randInterval(k)<GetSecs) % additional inteval to wait
            flag2=1;
            Screen('DrawTexture', won, clockTexture, []);%, rect_clock);
            Screen('DrawLine', won, 0, centre(1), centre(2), x, y, 3);
            Screen(won,'Flip', 0, 1);
        else theta = theta+2*pi*1/numUnits;
        end
    end
    
%     stop(noise);
    
%     if keypressed~=96 % 97 is one, 96 is zero
%         warn=1;      
%     end
    
    % transform thetas to msec
    % when theta equals zero it points at 15, 2pi=60
    factor=(mod(thetaPressed, (2*pi)))/(2*pi);
    clockNumberPressed=15+factor*60;
    if clockNumberPressed>60
        clockNumberPressed=clockNumberPressed-60;
    end
    startingPosition=15+60*startingTheta(k)/(2*pi);
    
    % number of periods completed
    periodsCompleted=thetaPressed/(2*pi);
    
    %% response
    t0=GetSecs;
    response=Ask(won,'Enter estimated clock time  ',[],[],'GetChar',rectmessage,'center', 24);
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
    
    % converting to ms
    conversionFactor=1000*T/60;
    errorInMs=error*conversionFactor;
    
    % warn if taking too long
    
    if RT2>8
        warn=2;
    end
    
    % different warnings to subjects according to flag or lack of response
%     if warn==1
%         DrawFormattedText(won, 'Please make sure you press the correct button', 'center', 'center');
%         Screen(won,'Flip');
%         WaitSecs(2);
    if RT1>10
        DrawFormattedText(won, 'Please try to press the button a bit faster', 'center', 'center');
        Screen(won,'Flip');
        WaitSecs(2);
    elseif warn==2
        DrawFormattedText(won, 'Please try to enter the time a bit faster', 'center', 'center');
        Screen(won,'Flip');
        WaitSecs(2);
    end
    
   
    Results(k,1)=clockNumberPressed;
    Results(k,2)=estimate;
    Results(k,3)=RT1;
    Results(k,4)=RT2;
    Results(k,5)=randInterval(k);
    Results(k,6)=startingTheta(k);
    Results(k,7)=startingPosition;
    Results(k,8)=thetaPressed;
    Results(k,9)=periodsCompleted;
    Results(k,10)=conditions(k);
    Results(k,11)=warn;
    Results(k,12)=error;
    Results(k,13)=errorInMs;
    
    
    Priority=0;
    clc;
    k=k+1;

end

Screen('CloseAll');

commandwindow;
clc;

%% creating data files %%
% warning off MATLAB:xlswrite:AddSheet;
% status1=xlswrite(subject, Results, filename);
% if (status1==1)
%      disp('creating dat file was successfully completed')
% else disp('!!!!!error occurred in creating dat file!!!!!!')
% end
csvwrite([subject,filename, '.csv'], Results);