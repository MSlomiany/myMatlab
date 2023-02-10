%% Initialize script %%
clear
clc
close all
fclose('all');

%% Configure serial port %%
serialPort = serialport("COM4",460800);

%% Configure digital multimeter as TCP/IP device %%
% ip_address = "192.168.1.5";
% digitalMultimeter = tcpclient(ip_address, 5025);
digitalMultimeter = visadev("TCPIP0::192.168.1.5::inst0::INSTR");

%% Clean *.txt files to save new data %%
delete IMUdata.txt
delete DMMdata.txt

%% Capture data %%

% Set measurement duration time
% To set measurement time change last argument in t object constructor
t = timer('TimerFcn', 'stat=false;', 'StartDelay', 60*15);

% Set auxiliary variables
i = 1;          % Set loop iterator to 1
stat = true;    % Set loop condition to true

% Start measurements
start(t)        % Start timer
tic             % Set second timer to timestamp DMM measurements

% Measurement loop
while(stat==true)
    % Read serial port data from IMU
    writelines(readline(serialPort), "IMUdata.txt", "WriteMode", "append");

    % Read DMM measurements every 50 loop iterations. As DMM measuremets
    % take more time than IMU reading from serial port, DMM measurements
    % frequency MUST BE SIGNIFICANTLY LOWER than IMU readings frequency to
    % aviod timing desynchronization
    if(mod(i,50) == 0 || i == 1)
        writelines(toc+","+writeread(digitalMultimeter, "MEASure:TEMPerature?"), "DMMdata.txt", "WriteMode", "append");
    end

    % Increment iterator
    i = i + 1;
end

% End measurements, clear timer object
stop(t);
delete(t);
clear i stat

%% Read data from *.txt files %%
TIMU = readtable("IMUdata.txt");
TDMM = readtable("DMMdata.txt");

% Change names in DMM data to avoid names conflicts
TDMM = renamevars(TDMM,["Var1","Var2"],["toc","t"]);

%% Convert IMU data to timetable %%

% Remove first measurement as MATLAB sometimes read first data frame
% incomplete.
TIMU = TIMU(3:end,:);

% Convert first column to datetime variable
time = milliseconds(TIMU.Var1);

% Convert table to timetable and set start time to 0 seconds. Remove first
% column with oryginal non-datetime timestamps and set previously converted
% 'time' table with datetime timestamps as RowTimes.
TIMU = table2timetable(TIMU(:,2:end),'RowTimes',time);
TIMU.Properties.StartTime = seconds(0);

% Calculate measurement duration time and frequency
duration = TIMU.Time(end);
freq = 1 / (seconds(duration) / height(TIMU));

%% Convert DMM data to timetable %%

% Convert first column to datetime variable
time = seconds(TDMM.toc);

% Convert table to timetable. Remove first column with oryginal
% non-datetime timestamps and set previously converted 'time' table with
% datetime timestamps as RowTimes. In this case don't set start time to 0
% seconds as DMM measurements has significantly lower freqency than IMU.
TDMM = table2timetable(TDMM(:,2),'RowTimes',time);

%% Plot captured data %%

myAuxPlot();
plot(TIMU.Time, TIMU.Var2);
plot(TDMM.Time, TDMM.t);

myAuxPlot();
plot(TIMU.Time, [TIMU.Var3, TIMU.Var4, TIMU.Var5]);

myAuxPlot();
plot(TIMU.Time, [TIMU.Var6, TIMU.Var7, TIMU.Var8]);

disp("IMU: "+seconds(duration));
disp("DMM: "+seconds(TDMM.Time(end)));
disp("Delta: "+seconds(duration-TDMM.Time(end)));

prompt = "To save data type filename. To continue, press enter: ";
txt = input(prompt, "s");
if(~isempty(txt))
    save(strcat(txt,'.mat'),'TDMM','TIMU');
end

function [] = myAuxPlot()
    figure()
    hold on
    grid on
    grid minor
end