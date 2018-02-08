%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REMOTE DUNES DETECTION ON MARS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nemanja Stojoski and Michael Pellet
% 10.12.2017

clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Image_directory='F:\EPFL\2_Master\Semestre 3\Earth Imaging\Project\Images_to_analize'; %Directory where there are the images
%Image_directory='F:\EPFL\2_Master\Semestre 3\Earth Imaging\Project\LBP_Dunes_Mars\Images\ESP_052355_2070';
Save_image_overlayed = 1;   % 1 if you want to save a JPG image with an overlay of the zones with dunes 0 if you don't want to save the images (just compute percentage of surface covered with dune and write it in a .txt file)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PARAMETERS FOR COMPUTATION OF LBP AND K-NN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LBP
LBPWindowSize = 30; %Size of the cells when computing the LBP
Nb_of_Cells_LBP = 3; %(Number of cells in the REF_window = Nb_of_Cells_LBP^2)

numNeighbors = 8; %Number of neighbors
R=2; %Radius of circular pattern to select neighbors
rotLBP=true; %Rotation 

%% K-NN
k_knn = 9; %Number of classes

%%
ThresholdBinarize = 1.5; %Threshold to have only the 1st class (dunes) when making the BW image of dunes zone (pixels = 1 if dunes zone, 0 otherwise)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOADING AND LBP COMPUTATION OF REFERENCE DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read the references images and put all of them into a cell

Ref_dir='Images\References\';
d = dir(strcat(Ref_dir,'Img_REF_cl_*_*.jpg'));
NameRefImageFile = {d.name};

for j=1:size(NameRefImageFile,2)
    REFj = imread(cell2mat(strcat(Ref_dir,NameRefImageFile(j))));
    REFj = rgb2gray(REFj);
    REFj = imcrop(REFj, [0 0 ...
        (LBPWindowSize*floor(size(REFj,2)/LBPWindowSize))...
        (LBPWindowSize*floor(size(REFj,1)/LBPWindowSize))]); %crop the image so it size is a multiple of the LBP window
   
     REF(1,j) = {REFj};
end

%% Compute the LBP reference data for training

% Change the number of bins depending if rotation or not
if rotLBP == false
    numBins = numNeighbors+2; 
else
    numBins = numNeighbors*(numNeighbors-1)+3;
end

for j=1:size(NameRefImageFile,2)
  
% Extract unnormalized LBP features  
    lbpFeaturesREFj = extractLBPFeatures(REF{j},'CellSize',[LBPWindowSize...
        LBPWindowSize],'Normalization','None','Radius',R,'Upright',rotLBP); 
%%
% Reshape the LBP features into a _number of neighbors_ -by- _number of cells_ array to access histograms for each individual cell.
    lbpCellHistsREFj = reshape(lbpFeaturesREFj,numBins,[]); 
%%
% Normalize each LBP cell histogram using L1 norm.
    lbpCellHistsREFj = bsxfun(@rdivide,lbpCellHistsREFj,sum(lbpCellHistsREFj)); 
%%
    if j==1
        lbpCellHistsREF=lbpCellHistsREFj;
    else
        lbpCellHistsREF = [lbpCellHistsREF,lbpCellHistsREFj];
    end

end

%% LBP data for training
LBP_data_train_sc = transpose(lbpCellHistsREF);

%% Creat a vector with the labels of the training datas
for j=1:size(NameRefImageFile,2)
    a = cell2mat(NameRefImageFile(j));
    LBP_label_trainj = a(12:13);
    
    if j==1
        LBP_label_train= str2num(LBP_label_trainj)...
            *ones(1,Nb_of_Cells_LBP^2);
    else
        LBP_label_train = [LBP_label_train,str2num(LBP_label_trainj)...
            *ones(1,Nb_of_Cells_LBP^2)];
    end
end

LBP_label_train = transpose(LBP_label_train);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOADING AND LBP COMPUTATION OF TEST DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read the tests images and put all of them into a cell

Test_dir='Images\References\Test_Data\';
d = dir(strcat(Test_dir,'Img_TEST_cl_*_*.jpg'));
NameTESTImageFile = {d.name};

for j=1:size(NameTESTImageFile,2)
    TESTj = imread(cell2mat(strcat(Test_dir,NameTESTImageFile(j))));
    TESTj = rgb2gray(TESTj);
    TESTj = imcrop(TESTj, [0 0 ...
        (LBPWindowSize*floor(size(TESTj,2)/LBPWindowSize))...
        (LBPWindowSize*floor(size(TESTj,1)/LBPWindowSize))]); %crop the image so it size is a multiple of the LBP window
   
     TEST(1,j) = {TESTj};
end

%% Compute the LBP data for testing

for j=1:size(NameTESTImageFile,2)
  
% Extract unnormalized LBP features  
    lbpFeaturesTESTj = extractLBPFeatures(TEST{j},'CellSize',[LBPWindowSize...
        LBPWindowSize],'Normalization','None','Radius',R,'Upright',rotLBP); 
%%
% Reshape the LBP features into a _number of neighbors_ -by- _number of cells_ array to access histograms for each individual cell.
    lbpCellHistsTESTj = reshape(lbpFeaturesTESTj,numBins,[]); 
%%
% Normalize each LBP cell histogram using L1 norm.
    lbpCellHistsTESTj = bsxfun(@rdivide,lbpCellHistsTESTj,sum(lbpCellHistsTESTj)); 
%%
    if j==1
        lbpCellHistsTEST=lbpCellHistsTESTj;
    else
        lbpCellHistsTEST = [lbpCellHistsTEST,lbpCellHistsTESTj];
    end

end

%% LBP data for test
LBP_data_test_sc = transpose(lbpCellHistsTEST);

%% Creat a vector with the labels of the test datas
for j=1:size(NameTESTImageFile,2)
    a = cell2mat(NameTESTImageFile(j));
    LBP_label_testj = a(13:14);

    if j==1
        LBP_label_test= str2num(LBP_label_testj)...
            *ones(1,((floor(size(TEST{j},2)/LBPWindowSize))...
            *(floor(size(TEST{j},1)/LBPWindowSize))));
    else
        LBP_label_test = [LBP_label_test,str2num(LBP_label_testj)...
            *ones(1,((floor(size(TEST{j},2)/LBPWindowSize))...
            *(floor(size(TEST{j},1)/LBPWindowSize))))];
    end
    
end

LBP_label_test = transpose(LBP_label_test);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TRAINING OF K-NN MODEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

typeNorm = 'minmax'; % use 'std' to rescale to a unit variance and zero mean
[LBP_data_train_sc, dataMax, dataMin] = ...
    classificationScaling(double(LBP_data_train_sc), [], [], typeNorm);
LBP_data_test_sc = ...
    classificationScaling(double(LBP_data_test_sc), dataMax, dataMin, typeNorm);

% Train a k-NN model
LBP_model_knn = fitcknn(LBP_data_train_sc,LBP_label_train,'NumNeighbors',k_knn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COMUPTE ACRUACY MEASURES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run the trained classifier on the validation set
class_knn_test = predict(LBP_model_knn,LBP_data_test_sc);

% Get the Confusion tables
CT_knn = confusionmat(LBP_label_test, class_knn_test); % build confusion matrix

% Get OVerall Accuracies
OA_knn = trace(CT_knn)/sum(CT_knn(:));

% Get Kappa statistics
CT_knn_percent=CT_knn./sum(sum(CT_knn));
EA_knn = sum(sum(CT_knn_percent,1)*sum(CT_knn_percent,2));
Ka_knn= (OA_knn - EA_knn)/(1-EA_knn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOADING AND LBP COMPUTATION OF IMAGES (WITH DUNES(MAYBE:)))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Load the image name and directory as well as the txt data for each image
[Directory,NameImageFile,TxtData]=Read_text_file(Image_directory);

    %Signification of each line in TxtData:
    %   1:  MAP_PROJECTION_ROTATION [deg]
    %   2:  MAP_RESOLUTION [px/deg]
    %   3:  MAP_SCALE [m/px]
    %   4:  MAXIMUM_LATITUDE [deg]
    %   5:  MINIMUM_LATITUDE [deg]
    %   6:  LINE_PROJECTION_OFFSET [px]
    %   7:  SAMPLE_PROJECTION_OFFSET [px]
    %   8:  EASTERNMOST_LONGITUDE [deg]
    %   9:  WESTERNMOST_LONGITUDE [deg]

%% Start the for loop in which all the images will be analysed
for j=1:size(NameImageFile,2)
    
    %Calculate the latitude at the center of the image
    Latitude = (TxtData(4,j)+TxtData(5,j))/2;
   
    %Calculate the longitude at the center of the image
    Longitude = (TxtData(8,j)+TxtData(9,j))/2;

%% Load reference image for histogram matching
    IMG_HIST_MATCH = imread('Images\References\Histogram_matching.jpg'); 

%% Load and put all the images in a cell of 1 x nb.images and do histogram matching with the reference image

    IMG = imread(cell2mat(strcat(Directory(j),'\',NameImageFile(j))));
    IMG = imhistmatch(IMG,IMG_HIST_MATCH); %
    IMG = imcrop(IMG, [0 0 (LBPWindowSize*floor(size(IMG,2)/LBPWindowSize))...
        (LBPWindowSize*floor(size(IMG,1)/LBPWindowSize))]); %crop the image so it size it a multiple of the LBP window

%% LBP
    
    % Extract unnormalized LBP features so that you can apply a custom normalization. 
    lbpFeatures = extractLBPFeatures(IMG,'CellSize',[LBPWindowSize...
        LBPWindowSize],'Normalization','None','Radius',R,'Upright',rotLBP); 
    %%
    % Reshape the LBP features into a _number of neighbors_ -by- _number of cells_ array to access histograms for each individual cell.
    lbpCellHists = reshape(lbpFeatures,numBins,[]); 

    % Normalize each LBP cell histogram using L1 norm.
    lbpCellHists = bsxfun(@rdivide,lbpCellHists,sum(lbpCellHists)); 

    LBP_data_sc = transpose(lbpCellHists);

    %% Rescale accordingly all image pixels
    LBP_data_sc = classificationScaling(double(LBP_data_sc),...
        dataMax, dataMin, typeNorm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CLASSIFICATION OF IMAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    statLoop=j %Jute to see the progression of the for loop

    % Classifying entire image for k-NN:
    LBP_class_knn = predict(LBP_model_knn,LBP_data_sc);

    %% Creat an image were pixels =1 if in dunes zone, 0 otherwise:
    LBP_class_knn_MAT = transpose(vec2mat(LBP_class_knn,...
        floor((size(IMG,1)/LBPWindowSize)))); %Creat a matrix of the size of the numbers of cells in the image
    LBP_class_knn_MAT_BW = imbinarize(LBP_class_knn_MAT,ThresholdBinarize); % Binarize with a threshold of 1.5 so there is only the classe 1 (dunes) that is remaining 
    LBP_class_knn_MAT_BW_comp = imcomplement(LBP_class_knn_MAT_BW); % To actualy have dunes => pixels =1, other stuff => pixels =0
    LBP_class_knn_MAT_BW_comp = ...
        imresize(LBP_class_knn_MAT_BW_comp ,[size(IMG)],'bicubic'); %Resize the image of dunes zone so it's the same as the original image

    %% Dunes counting on the image
    
    Number_of_dunes = Dunes_counter(IMG,LBP_class_knn_MAT_BW_comp);
        
    %% Evalation of the area covered with dunes on the image
    
    [Area_of_dunes,Percent_of_dunes] = Dunes_area(TxtData(3,j),LBP_class_knn_MAT_BW_comp);
    
    %%
    %Open text file at the begining
    if j==1
        fileID = fopen('Dunes_position.txt','w');
    else
    end
     
    %Write the Latitude, Longitude and Percentage of surface covered with dunes on the image in the text file:
    A = [Latitude; Longitude; Percent_of_dunes];
    fprintf(fileID,'%17.17f, %17.17f, %06.5f\r\n',A);
    
    %Close text file at the end
    if j==size(NameRefImageFile,2)
        fclose(fileID);
    else
    end
    %% Create and save an image with red dunes overlay
    if Save_image_overlayed==1
        Dunes_overlay = cat(3,255*uint8(LBP_class_knn_MAT_BW_comp),...
            zeros(size(LBP_class_knn_MAT_BW_comp)),...
            zeros(size(LBP_class_knn_MAT_BW_comp)));

            Dunes_overlay_smooth = imgaussfilt(Dunes_overlay,10); %to smooth a bit the overlay (as the overlay is made of cells of 30x30 px (so big squars)
        IMG_and_dunes_overlay = 1*cat(3, IMG, IMG, IMG)...
            + 0.9*Dunes_overlay_smooth;

        Name_images_overlayed = cell2mat(strcat(...
            'Images\Output_Images\','Dunes_overlay_',NameImageFile(j)));
        imwrite(IMG_and_dunes_overlay,Name_images_overlayed,'jpg');
    else
    end
end

