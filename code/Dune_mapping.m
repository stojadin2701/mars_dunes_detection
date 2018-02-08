%% LOADING AND MOSAICKING BASE MAP IMAGES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
numImages = 29;
map_images = cell(1, numImages);

for k = 1:numImages
    %load all images
    map_images{k} = imread(strcat('Project/mc', sprintf('%02d.jpg',k))); 
end

%merge the images north to south, east to west
mapTop = cat(1, map_images{1}, cat(2, map_images{2:7}));
mapUpper = cat(1, mapTop, cat(2, map_images{8:15}));
mapMiddle = cat(1, mapUpper, cat(2, map_images{16:23}));
mapLower= cat(1, mapMiddle, cat(2, map_images{24:29}));
%uncomment the next line to include the south pole
%map = cat(1, map_lower, map_images{30});
map = mapLower;


%% PLOTTING THE BASE MAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%latitude and longitude ranges
xValuesDeg = [-180 180];
yValuesDeg = [90 -65];

figure
np = newplot;
%set plot parameters
np.FontSize = 22;
np.Layer = 'top';
np.YDir = 'normal';
np.View = [0 90];
%display map
imagesc('XData', xValuesDeg, 'YData', yValuesDeg, 'CData', map)
colormap(gray);
axis equal tight
%label axes
xlabel('longitude [deg]');
ylabel('latitude [deg]');
title('Mars dune distribution');

%% PLOTTING DUNE DISTRIBUTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%load the file with dune distributions
M = csvread('Dunes_position.txt');

%itereate through matrix rows
for row = 1 : size(M, 1)
    %process each row
    dune = M(row, :);
    %obtain dune location and coverage from row
    duneCell = num2cell(dune);
    [lat, long, coverage] = duneCell{:};
    %skip images below -65 degrees latitude
    if lat < -65
        continue
    end
    %shift longitude range from [0, 360] to [-180, 180]
    if long >= 180
        long = long - 360;
    end
   
    %draw circle at the specified position
    h = viscircles(np, [long lat], 0.4);
    %set transparency of the drawn circle
    h.Children(1).Color = [1 0.6 0 coverage];
    h.Children(2).Color = [1 0.6 0 coverage];
end