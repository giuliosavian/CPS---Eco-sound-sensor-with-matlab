clear all;
close all;
%%
%create the session and get devices
session = daq.createSession('ni');
devices = daq.getDevices;

%SET-UP THE TIMING
%session.DurationInSeconds = 0.05;    %CHECK THIS ONE
session.Rate = 200000;       %one scan every 5us
session.IsContinuous = true;  %set the continuous acquisition mode
%create signal of 12.000 samples, and having Ts = 5us, we get a period of
%60 ms.
signal = [zeros(1,118998) 10*ones(1,2)  zeros(1,1000)];  

%set-up channels
trig_channel =  session.addAnalogOutputChannel(devices.ID , 'ao0' , 'Voltage');
echo_channel =  session.addAnalogInputChannel(devices.ID , 'ai1' , 'Voltage');
trig_channel.TerminalConfig='SingleEnded';
echo_channel.TerminalConfig='SingleEnded'; 

%signal to trigger
listener = session.addlistener('DataRequired' , @myFunction); %add listener to output buffer
lh = session.addlistener('DataAvailable',@detDist);  %add listener to input channel

high_value = 5; %set this high value
session.NotifyWhenScansQueuedBelow = 100000;  %Refill the buffer within 5ms
%session.IsNotifyWhenDataAvailableExceedsAuto = true;
session.NotifyWhenDataAvailableExceeds = 119999;  %IF NOT PROPERLY WORKING SET TO 11999
%%
%SIMULTANEOUS GENERATION AND ACQUISITION
session.queueOutputData(signal'); %initialize the output buffer

session.startBackground(); %generate and acquire simultanously
%inizializzation audio variables

%%
function myFunction(src, ~)
  persistent i;
  if(isempty(i))
    i = 2;
  elseif (i > 10)
    return
  else
    i = i+1;
  end

  signal = [zeros(1,118998) 10*ones(1,2)  zeros(1,1000)];   %12.000 samples signal  
  src.queueOutputData(signal');
  plot(signal);
  
  
  fprintf('Generation n.%d\n',i);
  figure(1);
  plot(signal,'-ko' ); title('ACQUISITION');
  hold on;
  
end

 
function detDist(~,event)
    persistent j;
  if(isempty(j))
    j = 1;
  elseif (j > 10)
    return
  else    
    j = j+1;
  end
    
    fprintf('Acquisition n.%d\n',j);
    figure(2);
    plot(event.Data,'-ko' );
    hold on;
    
    %high_value = 
    time = find(event.Data' > 0.5);
    k1 = time(1);
    k2 = time(end);
    HLtime = (k2-k1) / 200000; %compute the high time

    %distance 
    dis = 340*HLtime/2  %range from datasheet 2cm - 4m

    %scale distances range in frequency range
    minf = 1000;
    maxf = 380000;
    frequency = (dis-0.02)*(maxf-minf)/(4-0.02) + minf;
    y = [-1 1];
    player = audioplayer(y, frequency);
    play(player);
    
end