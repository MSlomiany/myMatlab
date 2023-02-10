%% Begin script %%
clear
clc
close all

%% Find latest *.mat file %%
d = dir('*.mat');
[~, index] = max([d.datenum]);
load(d(index).name);
%load testsyf.mat

%% Plot temperatures %%
figure()
plot(TIMU.Time, TIMU.Var2);
hold on
plot(TDMM.Time, TDMM.t);
grid on
grid minor

%% Plot accelerations %% 
figure()
plot(TIMU.Time, [TIMU.Var3, TIMU.Var4, TIMU.Var5]);
grid on
grid minor
hold on
ax = medfilt1(TIMU.Var3,50);
ay = medfilt1(TIMU.Var4,50);
az = medfilt1(TIMU.Var5,50);
plot(TIMU.Time, [ax,ay,az],'Color','yellow','LineWidth',2);

%% Plot rates %%
hold on
figure()
plot(TIMU.Time, [TIMU.Var6, TIMU.Var7, TIMU.Var8]);
grid on
grid minor

%% Plot both %%
figure()
grid on
grid minor
hold on
yyaxis left
plot(TIMU.Time, [TIMU.Var3, TIMU.Var4, TIMU.Var5],'LineStyle','-');
yyaxis right
plot(TIMU.Time, [TIMU.Var6, TIMU.Var7, TIMU.Var8],'LineStyle','-');


%% Display data informations %%
disp(d(index).name);
disp("IMU: "+seconds(TIMU.Time(end)));
disp("DMM: "+seconds(TDMM.Time(end)));
disp("Delta: "+seconds(TIMU.Time(end)-TDMM.Time(end)));
clear d index