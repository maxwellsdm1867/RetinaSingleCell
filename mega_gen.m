clear
num_cell = 5;
mega = cell(2,num_cell);
for i = 1:num_cell
    [fileName, filePath ] = uigetfile('*.mat');
    load([filePath '\' fileName])
    mega{1,i} = epochs;
    mega{2,i} = fileName(1:end-4);
end