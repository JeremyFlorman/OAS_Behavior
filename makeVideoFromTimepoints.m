function []= makeVideoFromTimepoints(folder, timepoint, windowInSeconds)

% folder  = 'C:\src\OpenAutoScope-v2\data\wt_food_tap_stimulus\2024-1-10_wt+tap\2024_01_10_13_27_11_flircamera_behavior';
% t0 = 31525;
% windowInSeconds = 30;

d = dir([folder '\*videoEvents.mat']);

if ~isempty(d)
    load(fullfile(d(1).folder,d(1).name))
else
    videoEvents = getVideoEvents(folder);
end



h5dir = dir([videoEvents.folder '\*.h5']);

fps = 15;
fPre = timepoint-(windowInSeconds*fps);
fPost = timepoint+(windowInSeconds*fps);




% Get the last frame number of each file
framenum = nan(length(h5dir),1);
for i = 1:length(h5dir)
    info = h5info(fullfile(h5dir(i).folder,h5dir(i).name), '/data');
    sz = info.Dataspace.Size;
    if i == 1
        framenum(i) =sz(3);
    else
        framenum(i) = framenum(i-1)+sz(3);
    end
end

if fPre<1
    fPre = 1;
end

if fPost > framenum(end)
    fPost = framenum(end);
end


% find what files contain the desired start and end frames
preidx = find(framenum>= fPre,1);
postidx = find(framenum>= fPost,1);

fileIndex = preidx:postidx;

catvid = [];
if postidx == preidx % if all of our frames in one file...

    fileName = fullfile(h5dir(preidx).folder,h5dir(preidx).name);
    info = h5info(fullfile(h5dir(preidx).folder,h5dir(preidx).name), '/data');
    sz = info.Dataspace.Size;

    if preidx == 1
        startframe = fPre;
    else
        startframe = mod(fPre, sz(3));
    end

    st = [1, 1, startframe];
    ct = [sz(1), sz(2), fPost-fPre];

    catvid = h5read(fileName, '/data', st, ct);

else
    for i = preidx:postidx % if they span multiple files, loop through

        fileName = fullfile(h5dir(i).folder,h5dir(i).name);
        info = h5info(fullfile(h5dir(i).folder,h5dir(i).name), '/data');
        sz = info.Dataspace.Size;

        if i == preidx % if we're reading the first video, find the start frame
            startframe = mod(fPre,sz(3));
            st = [1, 1, startframe];
            ct = [sz(1), sz(2), sz(3)-startframe];
            catvid = h5read(fileName,'/data',st, ct);


        elseif i>preidx && i<postidx % if we're reading a middle video, just read the whole thing
            tempdata = h5read(fileName,'/data',[1 1 1], sz);
            catvid = cat(3,catvid,tempdata);


        elseif i == postidx % if we're reading the last video, find how many frames we need to read
            ct = [sz(1), sz(2), fPost-framenum(i-1)];
            tempdata = h5read(fileName,'/data',[1 1 1], ct);
            catvid = cat(3,catvid,tempdata);
        end


    end
end
%%

outputFileName = strrep(h5dir(1).folder, 'flircamera_behavior', ['Frames_' num2str(fPre) '-' num2str(fPost) '.tif']);
if isfile(outputFileName)
    delete(outputFileName)
end 

for i = 1:size(catvid,3)
    t = linspace(-windowInSeconds,windowInSeconds, length(catvid));
    frm = fPre:fPost;
    position = [5 5; 5 20];
    text_str = {['Time: ' num2str(t(i))], ['Frame: ' num2str(frm(i))]};
    img = rgb2gray(insertText(catvid(:, :, i),position, text_str));
    imwrite(img, outputFileName, 'WriteMode', 'append','Compression','none');
end
% 
% figure();
% for i = 1:length(catvid)
%     t = linspace(-windowInSeconds,windowInSeconds, length(catvid));
%     frm = fPre:fPost;
%     imshow(catvid(:,:,i))
%     ax = gca;
%     text(ax,5,5,['Time: ' num2str(t(i))])
%     text(ax,5,20,['Frame: ' num2str(frm(i))])
%     drawnow();
% end
% 

end
