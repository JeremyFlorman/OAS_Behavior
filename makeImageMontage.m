folder  = 'C:\src\OpenAutoScope-v2\data\wt_food_tap_stimulus\2024-1-10_wt+tap\2024_01_10_13_27_11_flircamera_behavior';

d = dir([folder '\*videoEvents.mat']);
h5 = dir([folder '\*.h5']);

if ~isempty(d)
    load(fullfile(d(1).folder,d(1).name))
else
    videoEvents = getVideoEvents(folder);
end

x=videoEvents.xSteps;
y=videoEvents.ySteps;

if min(x)<0
    x = (x-min(x))+512;
end

if min(y)<0
    y = (y-min(y))+512;
end

scatter(x,y)


% img = h5Read(h5file, '/data', [1 1 i], [512,512,1]);
% imshow(img)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example data: x and y coordinates in millimeter units
x_steps = x;
y_steps = y;
% Image resolution and size
% imageResolution = 512;
% pixelSize_mm = 0.002614186;
% imageSize_mm = [1.338463, 1.338463];


% Image resolution and size
imageResolution = 512;
sizeOfOneImage = [512, 512];

% Create a blank canvas for the combined image
imgSz = max(max(y_steps),max(x_steps));

combinedImageSize = [max(y_steps) + sizeOfOneImage(1) - 1, max(x_steps) + sizeOfOneImage(2) - 1];
combinedImage = zeros(combinedImageSize);

locIdx = length(x_steps);
stepsize = 15;

for j = length(h5):-1:1
    h5file = fullfile(h5(j).folder,h5(j).name);
    info =h5info(h5file, '/data');

    h5Sz = info.Dataspace.Size;

    % Load and position each image onto the combined image
    for i =h5Sz(3):-stepsize:1%numel(x_pixels)

        img = fliplr(rot90(h5read(h5file, '/data', [1 1 i], [512,512,1])));
        sizeOfOneImage = [h5Sz(1), h5Sz(2)];  % Image resolution

        % Adjust x and y coordinates based on image size
        if ~isnan(x_steps(locIdx)) && ~isnan(y_steps(locIdx))
            x_position = x_steps(locIdx) - round(sizeOfOneImage(2) / 2); % Adjusted for center alignment
            y_position = y_steps(locIdx) - round(sizeOfOneImage(1) / 2); % Adjusted for center alignment

            % Check for overlapping pixels
            overlapRegion = combinedImage(y_position:y_position + sizeOfOneImage(1) - 1, x_position:x_position + sizeOfOneImage(2) - 1) > 0;

            % Create a logical index for non-overlapping pixels
            nonOverlapIndex = ~overlapRegion;

            % Position the image onto the combined image only for non-overlapping pixels
            combinedImage(y_position:y_position + sizeOfOneImage(1) - 1, x_position:x_position + sizeOfOneImage(2) - 1) = ...
                combinedImage(y_position:y_position + sizeOfOneImage(1) - 1, x_position:x_position + sizeOfOneImage(2) - 1) + double(img) .* nonOverlapIndex;
        end
        locIdx = locIdx-stepsize;

        % imshow(combinedImage, [100 256]);
        % line(x_steps(:),y_steps(:),2:3600)
        % set(gca, 'YDir', 'normal');
        % drawnow();
    end
end

% Display the combined image
imagesc(combinedImage, [50,256]);
colormap('bone')
line(x_steps(:),y_steps(:),1:length(x_steps));
set(gca, 'YDir', 'normal');



%% 
[xPt,yPt] = ginput(1); 
% Get (x,y) coordinates for all points
% *** This assumes the entire point was made with the one 
% call to scatter() instead of several calls to scatter(). 
h = gco(); 
hx = h.XData; 
hy = h.YData; 
hz = h.ZData; 
% Find the nearest point to selection
d = sqrt((xPt-hx).^2 + (yPt-hy).^2); 
[~,minIdx] = min(d); 

timepoint = hz(minIdx);



txt = input(['Save video at time: ' num2str(timepoint/15/60) ' min? (y/n)...'],"s")
if strcmp(txt,'y')
    makeVideoFromTimepoints(folder, timepoint, 30)
end

% 
% 
% h.ButtonDownFcn = @showZValueFcn;
% 
% %
% function [coordinateSelected, minIdx] = showZValueFcn(hObj, event,folder)
% %  FIND NEAREST (X,Y,Z) COORDINATE TO MOUSE CLICK
% % Inputs:
% %  hObj (unused) the axes
% %  event: info about mouse click
% % OUTPUT
% %  coordinateSelected: the (x,y,z) coordinate you selected
% %  minIDx: The index of your inputs that match coordinateSelected.
% 
% x = hObj.XData;
% y = hObj.YData; 
% z = hObj.ZData;
% pt = event.IntersectionPoint;       % The (x0,y0,z0) coordinate you just selected
% coordinates = [x(:),y(:),z(:)];     % matrix of your input coordinates
% dist = pdist2(pt,coordinates);      %distance between your selection and all points
% [~, minIdx] = min(dist);            % index of minimum distance to points
% coordinateSelected = coordinates(minIdx,:); %the selected coordinate
% % from here you can do anything you want with the output.  This demo
% % just displays it in the command window.
% % fprintf('[x,y,z] = [%.5f, %.5f, %.5f]\n', coordinateSelected)
% 
% timepoint = coordinateSelected(3);
% % 
% % txt = input(['Save video at time: ' num2str(timepoint/15/60) ' min? (y/n)...'],"s")
% % if strcmp(txt,'y')
%     makeVideoFromTimepoints(folder, timepoint, 30)
% % end
% end
