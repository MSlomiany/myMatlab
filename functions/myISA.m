function [p, T] = myISA(altitude, pref)
%MYBAROHEIGHT Summary of this function goes here
%   Detailed explanation goes here

arguments
    altitude (1,1) double
    pref (1,1) double = 101325;
end

% Temperature gradients
t = [-0.0065
    0.0
    0.0010
    0.0028
    0.0
    -0.0028
    -0.0020];

% Altitude ranges
h = [0
    11000
    20000
    32000
    47000
    51000
    71000
    80000];

% Base temperatures
Tref = [288.15
    216.65
    216.65
    228.65
    270.65
    270.65
    214.65];

% Constans
R = 287.05287;
g = 9.80665;

% Check altitude range
if altitude >= h(1) && altitude <= h(2)
    range = 1;
elseif altitude > h(2) && altitude <= h(3)
    range = 2;
elseif altitude > h(3) && altitude <= h(4)
    range = 3;
elseif altitude > h(4) && altitude <= h(5)
    range = 4;
elseif altitude > h(5) && altitude <= h(6)
    range = 5;
elseif altitude > h(6) && altitude <= h(7)
    range = 6;
elseif altitude > h(7) && altitude < h(8)
    range = 7;
else
    warning('Altitude out of range');
    p = 0;
    T = 0;
    return
end

if range > 1
    % Reference pressures array
    prefa = zeros(1,range);
    prefa(1) = pref;

    % Calculate reference pressures
    for i=2:range
        if(t(i-1) == 0)
            prefa(i) = prefa(i-1) * exp(-(g/(R*Tref(i-1)))*(h(i)-h(i-1)));
        else
            prefa(i) = prefa(i-1) * (1 + (t(i-1)/Tref(i-1)) * (h(i)-h(i-1)) ) ^ -(g/(t(i-1)*R));
        end
    end
else
    prefa = pref;
end

% Calculate pressure
if(t(range) == 0)
    p = prefa(range) * exp(-(g/(R*Tref(range)))*(altitude-h(range)));
else
    p = prefa(range) * (1 + (t(range)/Tref(range)) * (altitude-h(range)) ) ^ -(g/(t(range)*R));
end
T = Tref(range) + t(range) * (altitude - h(range));

end
