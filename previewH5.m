function [] = previewH5(h5Folder)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

h5Folder = 'C:\src\OpenAutoScope-v2\data\wt_food_tap_stimulus\2024-1-10_wt+tap\2024_01_10_13_27_11_flircamera_behavior';

d = dir([h5Folder '\*.h5']);
figure();
for i = 1:length(d)
    h5File = fullfile(d(i).folder, d(i).name);
    
    img = h5read(h5File, '/data');
    for j = 1:length(img)
        imshow(rot90(img(:,:,j),3))
        drawnow()
    end


end