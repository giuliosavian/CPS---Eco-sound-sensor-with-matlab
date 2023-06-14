clear all;
close all;
%create the session and get devices
session = daq.createSession('ni');
devices = daq.getDevices;

%set-up channels
trig_channel =  session.addAnalogOutputChannel(devices.ID , 'ao0' , 'Voltage');
echo_channel =  session.addAnalogInputChannel(devices.ID , 'ai1' , 'Voltage');

%session.DurationInSeconds = 0.05;    %CHECK THIS ONE
session.Rate = 200000;       %one scan every 5us
session.IsContinuous = true;  %set the continuous acquisition mode

trig_channel.TerminalConfig='SingleEnded';
echo_channel.TerminalConfig='SingleEnded'; 



%signal to trigger
%t = Ts:Ts:0.05;
listener = session.addlistener('DataRequired' , @myFunction); %add listener to output buffer
lh = session.addlistener('DataAvailable',@detDist);  %add listener to input channel

signal = [zeros(1,8,'uint16') 10*ones(1,2,'uint16') zeros(1,9990,'uint16') ];  %create signal (REVIEW LENGTH OF SIGNAL)
session.queueOutputData(signal); %put 


high_value = 5; %set this high value
session.NotifyWhenScansQueuedBelow = 9000;
session.NotifyWhenDataAvailableExceeds = 1000;
%inizializzation audio variables
y = [-1 1];
Fs = 100000; %between 1000- 380000
%%
%SIMULTANEOUS GENERATION AND ACQUISITION
session.startBackground(); %rivedere sintassi
wait(session) %wait for the session object to complete background generation
%%
function myFunction(src, event)
  signal = [zeros(1,8,'uint16') 10*ones(1,2,'uint16') zeros(1,9990,'uint16') ]; %SET RIGHT WITH PREVIOUS ONE
  src.queueOutputData(signal);
end

 
function detDist(src,event)
    k1 = find(event.Data(:,2) , high_value , 'first');
    k2 = find(event.Data(:,2) , high_value , 'last');
    HLtime = (k2-k1) / 200000; %compute the high time

    %distance 
    dis = 340*HLtime/2  %range from datasheet 2cm - 4m

    %scale distances range in frequency range
    minf = 1000;
    maxf = 380000;
    frequency = (dis-0.02)*(maxf-minf)/(4-0.02) + minf;
    
    player = audioplayer(y, frequency);
    play(player);
end