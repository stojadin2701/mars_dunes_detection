function [Directory,NameImageFile,TxtData]=Read_text_file(Image_directory)
%% Function used to read the name of the images and the text data (with lat, long, resolution, etc...)

d = dir(strcat(Image_directory,'\ESP_*_*_RED.LBL'));
NameTxtFile = {d.name};

d = dir(strcat(Image_directory,'\ESP_*_*_RED.NOMAP.browse.jpg'));
NameImageFile = {d.name};

Directory={d.folder};

for j=1:size(NameImageFile,2)
    fileID = fopen(strcat(char(Directory(j)),'\',char(NameTxtFile(j))),'r');
    TxtDataj = cell2mat(textscan(fileID, '%f', 'Delimiter',','));
    fclose(fileID);
    
    if j==1
        TxtData=TxtDataj;
    else
        TxtData = [TxtData,TxtDataj];
    end
    
end    
