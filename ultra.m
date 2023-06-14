
%set-up parameters
session.IsContinuous=1;
session.Rate = 200000;       %one scan every 5us
session.DurationInSeconds = 0.05; %duration of the timing diagram is 50ms
session.IsContinuous=1;
session.NotifyWhenScansQueuedBelow = 4000000;
session.NotifyWhenDataAvailableExceeds = ;

%set-up channels
trig =  session.addAnalogOutputChannel(devices.ID , 'ao0' , 'Voltage');
echo =  session.addAnalogInputChannel(devices.ID , 'ai0' , 'Voltage');

%inizializzation audio variables
y = [-1 1];
Fs = 100000; %between 1000- 380000

%set-up listener
listener_trig = session.addlistener('DataRequired', @myFunction);
listener_echo = session.addlistener('DataAvailable',@Callback);

%signal to trigger
signal = [zeros(1,9997,'uint16') 10*ones(1,2,'uint16') zeros(1,1,'uint16')];  

%%
%made by myFunction
%signal = [ones(1,2,'uint16') zeros(1,10000,'uint16')];  %signal of 10002 scans with a rate of 200000 makes 0.05s 

%put trigger in queue
session.queueOutputData(signal');
%%

%send trigger and acquire echo
session.startBackground()

% load echo data
load log.mat event.Timestamps event.Data

%compute distance
threeshold = 0.05;
k1 = find(echosignal > threeshold,1,'first');
k2 = find(echosignal > threeshold,1,'last');
HLtime = (k2-k1) /200000

%scale distances range in frequency range
minf = 1000;
maxf = 380000;
frequency = (dis-0.02)*(maxf-minf)/(4-0.02) + minf;

%generate audio signal
player = audioplayer(y, Fs);
play(player);


