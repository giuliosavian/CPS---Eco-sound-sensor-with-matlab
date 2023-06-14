%create session
session = daq.createSession('ni');
devices = daq.getDevices;

%%
%set-up parameters
session.IsContinuous=1;
session.Rate = 200000;       %one scan every 5us
%session.DurationInSeconds = 0.05; %duration of the timing diagram is 50ms

session.NotifyWhenScansQueuedBelow = 100; 
% when the queue reach 100 samples (small) it is refilled with 20000
% samples that needs 10000/rate = 0.05s = 50ms for return to 100 samples

session.NotifyWhenDataAvailableExceeds = 10000;
%NOTE:
%deltaT = NotifyWhenDataAvailableExceeds/Rate = 0.05s = 50ms
%deltaT must be >=  Telaboration

%%
%set-up channels
trig =  session.addAnalogOutputChannel(devices.ID , 'ao0' , 'Voltage');
echo =  session.addAnalogInputChannel(devices.ID , 'ai0' , 'Voltage');

%%
%inizializzation audio variables
y = [-1 1];
Fs = 100000; %between 1000- 380000

%%
%set-up listener
listener_trig = session.addlistener('DataRequired', @myFunction);
listener_echo = session.addlistener('DataAvailable',@Callback);

%signal to trigger
signal = [zeros(1,9997,'uint16') 10*ones(1,2,'uint16') zeros(1,1,'uint16')];  

%put trigger in queue
session.queueOutputData(signal');

%%
%generate trigger and acquire echo continuously
session.startBackground()

% load echo data
load log.mat event.Timestamps event.Data

%%
%compute distance
threeshold = 0.5; %no acquiring noise
k1 = find(echosignal > threeshold,1,'first');
k2 = find(echosignal > threeshold,1,'last');
HLtime = (k2-k1) /200000

%scale distances range in frequency range
minf = 1000;
maxf = 380000;
frequency = (dis-0.02)*(maxf-minf)/(4-0.02) + minf;

%%
%generate audio signal
player = audioplayer(y, Fs);
play(player);

%%
function Callback(~,event) %src: name of session obj ,
%event:daq.DataAvailable
    persistent i;
    if(isempty(i))
        i = 1;
    else
        i = i+1;
    save log.mat event.Timestamps event.Data
    end 
fprintf('Acquisition n.%d\nn',i);
plot(event.Timestamps,event.Data,'-ko' );  %R-T plot
end
%daq.DataAvailableInfo.Timestamps: timing info
%daq.DataAvailableInfo.Data: acquired data end

function myFunction(~,~)
    signal = [zeros(1,19997,'uint16') ones(1,2,'uint16')  zeros(1,1,'uint16')];  %signal of 10002 scans with a rate of 200000 makes 0.05s 
    %put trigger in queue
    session.queueOutputData(signal');
end