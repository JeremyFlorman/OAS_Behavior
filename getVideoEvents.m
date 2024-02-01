function [videoEvents] = getVideoEvents(h5Folder,videotimes)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if nargin<1
    h5Folder = 'C:\src\OpenAutoScope-v2\data\wt_food_tap_stimulus\2024-1-10_wt+tap\2024_01_10_13_27_11_flircamera_behavior';
end

if nargin<2
    videotimes = getVideoTimeStamps(h5Folder);
end
xLoc = nan(length(videotimes),1);
yLoc = nan(length(videotimes),1);
xSteps = nan(length(videotimes),1);
ySteps = nan(length(videotimes),1);
mmPerStep = 0.001307092;
fps=15;



[pth,~,~] = fileparts(h5Folder);
logd = dir([pth '\*log.txt']);

for i =1:length(logd)
    fid = fopen(fullfile(logd(i).folder, logd(i).name),"r");

    while~feof(fid)
        line = fgetl(fid);
        l = regexp(line, ' ', 'split');
        lTime = str2double(l{1}); % time at current line

        % only look at log events during our recording
        if lTime > videotimes(1) && lTime < videotimes(end)
            if contains(line, 'tracker_behavior received position')
                locTime = alignEvent(line,videotimes);

                pattern = '(-?\d+),(-?\d+),(-?\d+)'; % Pattern to match three numbers separated by commas
                r = regexp(line, pattern, 'tokens');
                if ~isempty(r)
                r=r{:};
                xSteps(locTime,1) = str2double(r{1,1});
                ySteps(locTime,1) = str2double(r{1,2});
                xLoc(locTime,1) = str2double(r{1,1})*mmPerStep; % X coordinate in mm units
                yLoc(locTime,1) = str2double(r{1,2})*mmPerStep; % Y coordinate in mm units
                end
                % r = regexp(line,'(', 'split');
                % r = regexp(r{end}, '\d+', 'match');
                % 
                % % % check for crossing origin % %
                % if abs(xl)<originThreshold
                %     if abs(xl)-abs(xLoc(locTime-1,1))>=0
                %         xflip = xflip*-1;
                %     end
                % end
                % 
                % if abs(yl)<originThreshold
                %     if abs(yl)-abs(yLoc(locTime-1,1))>=0
                %         yflip = yflip*-1;
                %     end
                % end
                % 
                % % % convert orgin crossings to negative coordinates % %
                % xLoc(locTime,1) = xl*xflip;
                % yLoc(locTime,1) = yl*yflip;



            end
        end
    end
end


velocity =NaN(length(videotimes),1);

for i = 2:length(xLoc)-(fps+1)
    dx = xLoc(i)-xLoc(i+fps); %change in xLoc per second
    dy = yLoc(i)-yLoc(i+fps); %change in yLoc per second
    velocity(i) = sqrt(dx.^2 + dy.^2);
end

velocity(velocity>0.5) = NaN;

videoEvents.velocity = velocity;
videoEvents.xLoc = xLoc;
videoEvents.yLoc = yLoc;
videoEvents.xSteps = xSteps;
videoEvents.ySteps = ySteps;
videoEvents.videotimes = videotimes;
videoEvents.folder = h5Folder;
spltnm = strsplit(h5Folder, '\');
outname = [h5Folder '\' spltnm{end} '_videoEvents.mat'];
save(outname, "videoEvents");

    function [idx] = alignEvent(event, time)
        et = regexp(event, ' ', 'split');
        eTime = str2double(et{1});
        idx = find(time>=eTime,1);
    end
end
