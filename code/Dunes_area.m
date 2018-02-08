function [Area_of_Dunes,Percent_of_Dunes] = Dunes_area(resolution,dunes_zone)
%% Function used to calculate the area covered with dunes
%count the number of pixels in zones where there is dunes (eg white pixels) 
Number_of_pixel = round(sum(dunes_zone(:))); 

%claculate the area where there are dunes (in m^2)
Area_of_Dunes = Number_of_pixel*(resolution^2)

%calculate the ratio of the image covered with dunes
Percent_of_Dunes = Number_of_pixel/(size(dunes_zone,1)*size(dunes_zone,2))



