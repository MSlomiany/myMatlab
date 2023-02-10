utility.init();
utility = utility(0,0,0); %print close next

load fugoida.mat;

Acceleration.Properties.StartTime = seconds(0);
Acceleration.Properties.SampleRate = 50;
AngularVelocity.Properties.StartTime = seconds(0);
AngularVelocity.Properties.SampleRate = 50;
MagneticField.Properties.StartTime = seconds(0);
MagneticField.Properties.SampleRate = 50;
Orientation.Properties.StartTime = seconds(0);
Orientation.Properties.SampleRate = 50;
Position.Properties.StartTime = seconds(0);
Position.Properties.SampleRate = 1;

%% Wysokość
figure()
hold on
plot(Position.Timestamp, Position.altitude);

drawAreas(0);
title("Altitude");
xlabel("Time [s]");
ylabel("altitude [m], MSL");
xlim([0 Position.Timestamp(end)]);
grid minor

%% Ground Speed
figure()
grid minor
plot(Position.Timestamp, Position.speed);

drawAreas(0);
title("Ground speed");
xlabel("Time [s]");
ylabel("speed [$m/s$]");
xlim([0 Position.Timestamp(end)]);

%% Przyśpieszenie
figure()
hold on
Acceleration.Xs = smoothdata(Acceleration.X,"loess","SmoothingFactor",.4);
plot(Acceleration.Timestamp, Acceleration.Xs, 'LineWidth', 2);

plot(Acceleration.Timestamp, Acceleration.X, 'Color', 'red');
plot(Acceleration.Timestamp, Acceleration.Y, 'Color', 'blue');
plot(Acceleration.Timestamp, Acceleration.Z, 'Color', 'magenta');

legend("Z filtered", "Z", "Y", "X","AutoUpdate","off");
drawAreas(1);
title("Acceleration");
xlabel("Time [s]");
ylabel("acceleration [$m/{s^{2}}$]");
xlim([0 Acceleration.Timestamp(end)]);

%% Orientation
figure()
hold on
plot(Orientation.Timestamp, Orientation.X, 'Color', 'red');
plot(Orientation.Timestamp, Orientation.Y, 'Color', 'blue');
plot(Orientation.Timestamp, Orientation.Z + 90, 'Color', 'magenta');

legend("$\Psi$", "$\Theta$", "$\Phi$","AutoUpdate","off");
drawAreas(1);
title("Atitude");
xlabel("Time [s]");
ylabel("angle [$^{\circ}$]");
xlim([0 Orientation.Timestamp(end)]);

%% Theta
figure()
hold on
Orientation.Ys = smoothdata(Orientation.Y,"loess","SmoothingFactor",.4);
plot(Orientation.Timestamp, Orientation.Ys, 'LineWidth', 1);
plot(Orientation.Timestamp, Orientation.Y, 'Color', '#bcbec2');

drawAreas(1);
title("Theta");
xlabel("Time [s]");
ylabel("angle [$^{\circ}$]");
xlim([0 Orientation.Timestamp(end)]);

%% Prędkości kątowe
figure()
hold on
plot(AngularVelocity.Timestamp, AngularVelocity.X, 'Color', 'red');
plot(AngularVelocity.Timestamp, AngularVelocity.Y, 'Color', 'blue');
plot(AngularVelocity.Timestamp, AngularVelocity.Z, 'Color', 'magenta');

legend("$r$", "$q$", "$p$","AutoUpdate","off");
drawAreas(1);
title("Angular velocity");
xlabel("Time [s]");
ylabel("angular velocity [$^{\circ}/s$]");
xlim([0 AngularVelocity.Timestamp(end)]);

%% Trasa przelotu
figure()
geoplot(Position.latitude, Position.longitude,"Color",'yellow','LineWidth',2);
geobasemap satellite

%% Plot 3D
figure()
plot3(Position.latitude, Position.longitude, Position.altitude,"Color",'blue',"LineWidth",2);
zlabel('altitude [m]');
xlabel('latitude [$^{\circ}$]');
xlabel('longitude [$^{\circ}$]');

%% MAPA 3D
uif = uifigure();
g = geoglobe(uif);
geoplot3(g,Position.latitude, Position.longitude, Position.altitude,"Color",'yellow',"LineWidth",2);

%% Analiza oscylacji
xbeg = seconds(377);
xend = seconds(446);
S = timerange(xbeg,xend);
osc = Position(S,:);
osc = retime(osc,'regular','spline','SampleRate',50);

figure();
yyaxis right
plot(osc.Timestamp, osc.altitude, 'Color', 'green', 'LineWidth', 2);
ylabel("altitude [m], MSL");
xlabel("Time [s]");

yyaxis left
plot(osc.Timestamp, osc.speed, 'Color', 'blue', 'LineWidth', 2);
ylabel("speed [$m/s$]");

legend("speed [$m/s$]", "altitude [m]", 'AutoUpdate', 'off');
title("Analiza oscylacji fugoidalnej");

%% Szukanie ekstremów lokalnych w wysokości
peaks = find(islocalmax(osc.altitude));
troughs = find(islocalmin(osc.altitude));
Date = osc.Timestamp([peaks; troughs]);
Value = osc.altitude([peaks; troughs]);
Type = categorical([zeros(size(peaks)); ones(size(troughs))],[0 1],["peak","trough"]);
AextremaEvents = sortrows(timetable(Date,Type,Value));

yyaxis right
isPeak = (AextremaEvents.Type == "peak");
plot(AextremaEvents.Date(isPeak),AextremaEvents.Value(isPeak),"y^","MarkerFaceColor","red","MarkerSize",10);
isTrough = (AextremaEvents.Type == "trough");
plot(AextremaEvents.Date(isTrough),AextremaEvents.Value(isTrough),"yv","MarkerFaceColor","red","MarkerSize",10);

% Ważne
IntCounter = 1;

arr = AextremaEvents.Date(isPeak);
sum = 0;
for i=1:length(arr)-1
    sum = sum + arr(i+1) - arr(i);
    IntArray(IntCounter) = arr(i+1) - arr(i); %#ok<SAGROW> 
    IntCounter = IntCounter + 1;
end
avg = sum / (length(arr) - 1);
display(avg);

arr = AextremaEvents.Date(isTrough);
sum = 0;
for i=1:length(arr)-1
    sum = sum + arr(i+1) - arr(i);
    IntArray(IntCounter) = arr(i+1) - arr(i);
    IntCounter = IntCounter + 1;
end
avg = sum / (length(arr) - 1);
display(avg);

%% Szukanie ekstremów lokalnych w speedzie
peaks = find(islocalmax(osc.speed));
troughs = find(islocalmin(osc.speed));
Date = osc.Timestamp([peaks; troughs]);
Value = osc.speed([peaks; troughs]);
Type = categorical([zeros(size(peaks)); ones(size(troughs))],[0 1],["peak","trough"]);
SextremaEvents = sortrows(timetable(Date,Type,Value));

yyaxis left
isPeak = (SextremaEvents.Type == "peak");
plot(SextremaEvents.Date(isPeak),SextremaEvents.Value(isPeak),"y^","MarkerFaceColor","red","MarkerSize",10);
isTrough = (SextremaEvents.Type == "trough");
plot(SextremaEvents.Date(isTrough),SextremaEvents.Value(isTrough),"yv","MarkerFaceColor","red","MarkerSize",10);

arr = SextremaEvents.Date(isPeak);
sum = 0;
for i=1:length(arr)-1
    sum = sum + arr(i+1) - arr(i);
    IntArray(IntCounter) = arr(i+1) - arr(i);
    IntCounter = IntCounter + 1;
end
avg = sum / (length(arr) - 1);
display(avg);

arr = SextremaEvents.Date(isTrough);
sum = 0;
for i=1:length(arr)-1
    sum = sum + arr(i+1) - arr(i);
    IntArray(IntCounter) = arr(i+1) - arr(i);
    IntCounter = IntCounter + 1;
end
avg = sum / (length(arr) - 1);
display(avg);

xlim([osc.Timestamp(1) osc.Timestamp(end)]);

%% Analiza oscylacji - theta
osc = Orientation(S,:);
osc.Ys = smoothdata(osc.Y,"loess","SmoothingFactor",.05);

figure();
plot(osc.Timestamp, osc.Ys, 'LineWidth', 2, 'Color', 'blue');
plot(osc.Timestamp, osc.Y, 'Color', '#bcbec2');

title("Theta");
xlabel("Time [s]");
ylabel("angle [$^{\circ}$]");
xlim([osc.Timestamp(1) osc.Timestamp(end)]);

peaks = find(islocalmax(osc.Ys));
troughs = find(islocalmin(osc.Ys));
Date = osc.Timestamp([peaks; troughs]);
Value = osc.Ys([peaks; troughs]);
Type = categorical([zeros(size(peaks)); ones(size(troughs))],[0 1],["peak","trough"]);
TextremaEvents = sortrows(timetable(Date,Type,Value));

isPeak = (TextremaEvents.Type == "peak");
plot(TextremaEvents.Date(isPeak),TextremaEvents.Value(isPeak),"y^","MarkerFaceColor","red","MarkerSize",10);
isTrough = (TextremaEvents.Type == "trough");
plot(TextremaEvents.Date(isTrough),TextremaEvents.Value(isTrough),"yv","MarkerFaceColor","red","MarkerSize",10);

arr = TextremaEvents.Date(isPeak);
sum = 0;
for i=1:length(arr)-1
    sum = sum + arr(i+1) - arr(i);
    IntArray(IntCounter) = arr(i+1) - arr(i);
    IntCounter = IntCounter + 1;
end
avg = sum / (length(arr) - 1);
display(avg);

arr = TextremaEvents.Date(isTrough);
sum = 0;
for i=1:length(arr)-1
    sum = sum + arr(i+1) - arr(i);
    IntArray(IntCounter) = arr(i+1) - arr(i);
    IntCounter = IntCounter + 1;
end
avg = sum / (length(arr) - 1);
display(avg);

%% Podsumowanie
averageOsc = mean(IntArray);
stdOsc = std(IntArray);
display(averageOsc);
display(stdOsc);

%% Koniec skryptu
utility.endscript();

function [] = drawAreas(wrong)

% 1
xbeg = seconds(377);
xend = seconds(446);
ybeg = min(ylim);
yend = max(ylim);
x = [xbeg xend xend xbeg];
y = [ybeg ybeg yend yend];
fill(x,y,'g','FaceAlpha',0.3,'EdgeColor','none');
% 2
xbeg = seconds(477);
xend = seconds(532);
ybeg = min(ylim);
yend = max(ylim);
x = [xbeg xend xend xbeg];
y = [ybeg ybeg yend yend];
fill(x,y,'g','FaceAlpha',0.3,'EdgeColor','none');
% corrupted data
if wrong == 1
    xbeg = 543;
    xend = 569;
    ybeg = min(ylim);
    plot([xbeg xend],[ybeg ybeg],"r-","LineWidth",6);
end

set(gca, 'Children', flipud(get(gca, 'Children')))

end