function [MIMU, MDMM] = myDataMerge(varargin, options)
%MYDATAMERGE This function merges data from different measurements series
%   Input arguments are names of the *.MAT files in the desired order to
%   be sorted.
%
%   Data from Digital Multimeter (TDMM timetable) will be retimed to match
%   times of the IMU data. If longer, data from DMM will be truncated, if
%   shorter - extrapolated.
%
%   StartTime property of consecutive timetables will be set as EndTime of
%   the previous timetable plus a calculated step size.
%
%   If only one data file is provided, DMM data will be trimmed to match
%   IMU times.

arguments(Repeating)
    varargin
end
arguments
    options.name
end

% This loop is merging all provided timetables
for i = 1:nargin
    % Try to read *.mat file
    try
        load(varargin{i}+".mat", 'TIMU', 'TDMM');
    catch
        % Throw error if name is incorrect
        error("Incorrect file name!");
    end

    % Retime DMM timetable
    TDMM = retime(TDMM, TIMU.Time, 'makima');

    % Merge to output file
    if i == 1
        % In first iteration assign timetables from loaded data to output
        % arrays
        MIMU = TIMU;
        MDMM = TDMM;
    else
        % Function set a start time of a new timetable as a last timestamp
        % from previous timetable and adds 7 miliseconds (timestep with
        % approximately 150 Hz sampling)
        newStartTime = MIMU.Time(end);
        newStartTime = newStartTime + milliseconds(7);
        TIMU.Properties.StartTime = newStartTime;
        TDMM.Properties.StartTime = newStartTime;

        % In any following iterations append new arrays to an existing
        % output array

        % Warning of the array changing size every iteration is now
        % suppressed. Don't delete #ok command at the end of the following
        % lines.
        MIMU = [MIMU; TIMU]; %#ok
        MDMM = [MDMM; TDMM]; %#ok
    end

    % Clear loaded data
    clear TIMU
    clear TDMM
end

% Save to file with T*** names to bo compliant with dataViever
% script/function
TIMU = MIMU;
TDMM = MDMM;

% Save new timetables to .*mat file
if(isfield(options,"name"))
    save(options.name+".mat",'TIMU','TDMM');
else
    save(varargin{1}+"_merged.mat",'MIMU','MDMM');
end

end