function [time] = getVideoTimeStamps(h5Folder)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% h5Folder = 'C:\src\OpenAutoScope-v2\data\wt_food_tap_stimulus\2024-1-10_wt+tap\2024_01_10_13_27_11_flircamera_behavior';
d = dir([h5Folder '\*.h5']);

for i = 1:length(d)
    h5path = fullfile(d(i).folder,d(i).name);
    temptime = h5read(h5path, '/times');
      
    if i == 1
        time = temptime;
    else
        time = cat(1,time, temptime);
    end
end
reltime = diff(time);