fld = 'C:\src\OpenAutoScope-v2_20240205_1502\data\300mM_NaCl';

imgDir = dir([fld '\**\*behavior\*.h5']);
imgDir = unique({imgDir.folder});

for i = 2:length(imgDir)
    d = dir([imgDir{i} '\*.h5']);
    fileparts = strsplit(imgDir{i},'\');
    experimentSuffix = [fileparts{end-1} '_' num2str(i) '.tif'];
    outputFileName = strrep(imgDir{i}, fileparts{end}, experimentSuffix);

%     outputFileName= [imgDir{i} '.tif'];

    if exist(outputFileName,'file')
        delete(outputFileName);
    end

    for j =1:length(d)
        h5path = fullfile(d(j).folder,d(j).name);
        data = h5read(h5path,'/data');
        if j == 1
            bfimg = data;
        elseif j>1
            bfimg = cat(3,bfimg, data);
        end
    end

    for k = 1:size(bfimg,3)
        imwrite(bfimg(:, :, k), outputFileName, 'WriteMode', 'append','Compression','none');
    end


end

