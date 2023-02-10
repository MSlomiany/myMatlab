function [temperature] = myLmTemperature(adc)
%MYLMTEMPERATURE Summary of this function goes here
%   Detailed explanation goes here
maxV = 3.3;
maxN = 2^12;

V = (maxV .* adc) ./ maxN; 

output = 10 / 1000;

K = V ./ output;

temperature = K - 273.15;

end

