function [] = previewH5(h5Folder)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

h5Folder = 'C:\src\OpenAutoScope-v2\data\foraging\240221_foraging\2024_02_21_11_15_40_flircamera_behavior';

d = dir([h5Folder '\*.h5']);
figure();
for i =15:length(d)
    h5File = fullfile(d(i).folder, d(i).name);
    
    img = h5read(h5File, '/data');
    for j = 1:length(img)
        imshow(img(:,:,j))
        % imshow(rot90(img(:,:,j),3))
        drawnow()
    end


end