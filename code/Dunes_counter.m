function [Number_of_Dunes] = Dunes_counter(IMG,dunes_zone)
%% Function used to count the number of dunes
%%Code in comment used to make figure with red points in the repport
%(with code at the end)
%IMG_preserved=IMG;

%Edge detection:
[IMG,threshold] = edge(IMG,'Prewitt',[]);
IMG = edge(IMG,'Prewitt',threshold*1.2); 
%Reduction of the edges to singles pixels:
IMG = bwmorph(IMG,'clean');
IMG = bwmorph(IMG,'thicken');
IMG = imfill(IMG, 'holes');
IMG = bwmorph(IMG,'shrink',inf);
%Multiplication of the singe pixels image with the image where dunes zone are white (so there are singles pixels only were there are dunes) 
IMG=immultiply(IMG,dunes_zone);


%%Code in comment used to make figure with red points in the report
%IMG = bwmorph(IMG,'thicken',1);
% IMG = cat(3,255*uint8(IMG),...
%             zeros(size(IMG)),...
%             zeros(size(IMG)));
%    IMG_and_dunes_overlay = 1*cat(3, IMG_preserved, IMG_preserved,...
%   IMG_preserved) + 0.9*IMG;
%         Name_images_overlayed = strcat(...
%             'Images\Output_Images\','Count_Dunes_overlay_test');
%         imwrite(IMG_and_dunes_overlay,Name_images_overlayed,'jpg');
      
Number_of_Dunes = round(sum(IMG(:))); 

