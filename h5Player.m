% Image Sequence Playback and Annotation App with HDF5 Support

% Create a figure for the app
appFig = uifigure('Name', 'Image Sequence Player', 'NumberTitle', 'off', 'Position', [160 159 784 504]);

% Initialize variables
appFig.h5FilePath = 'C:\src\OpenAutoScope-v2\data\wt_food_tap_stimulus\2024-1-10_wt+tap\2024_01_10_13_27_11_flircamera_behavior/000000.h5'; % Change this to the path of your HDF5 file
h.datasetName = '/data';
h.info = h5info(h5FilePath, datasetName);
h.numFrames = info.Dataspace.Size(end);
h.currentFrame = 1;

% Create UI components
imshowHandle = imshow(zeros(256, 256), []); % Placeholder for the image
slider = uicontrol('Style', 'slider', 'Min', 1, 'Max', numFrames, 'Value', 1, 'SliderStep', [1/(numFrames-1) 1/(numFrames-1)], 'Position', [20, 20, 600, 20], 'Callback', @sliderCallback);
playPauseButton = uicontrol('Style', 'togglebutton', 'String', 'Play', 'Position', [650, 20, 60, 30], 'Callback', @playPauseCallback);

% Function to update the displayed frame
function updateFrame(frame)
    currentImage = h5read(h5FilePath, datasetName, [1 1 frame], [256 256 1]);
    set(imshowHandle, 'CData', currentImage);
end

% Callback function for the slider
function sliderCallback(source, ~)
    currentFrame = round(get(source, 'Value'));
    updateFrame(currentFrame);
end

% Callback function for the play/pause button
function playPauseCallback(source, ~)
    if get(source, 'Value') == 1 % Play
        set(source, 'String', 'Pause');
        while get(source, 'Value') == 1
            currentFrame = currentFrame + 1;
            if currentFrame > numFrames
                currentFrame = 1;
            end
            set(slider, 'Value', currentFrame);
            updateFrame(currentFrame);
            pause(0.1); % Adjust the playback speed by changing the pause duration
            drawnow;
        end
    else % Pause
        set(source, 'String', 'Play');
    end
end