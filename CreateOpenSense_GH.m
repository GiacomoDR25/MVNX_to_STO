%% Generate Opensense file for kinematic analysis in OpenSim
%-----------------------------------------------------------
% Covert the rawData_*.mat in .sto format

clear; close all; clc;
%% Settings

% addpath of MexFiles folder
addpath('C:\GiacomoDR\OpenSense\DataTransform_Xsens_to_OS\CPP_Projects\MexFiles');
% Path where you are working on
DataPath = 'C:\GiacomoDR\OpenSense\CO_p3_walk\Xsens_data_processing';
% rawData.mat that want to convert in .sto
R = load(fullfile(DataPath,'rawData_CO_p3_walk_002.mat'));
%extern folder where the file .sto will be saved
OutPath = [DataPath '_Osens'];

%% Export the storage files

% The model used is the gait2392 so the important headers and IMU sensors are these below

% Headers contained in the rawData .mat file
Headers_MatF = {'Pelvis', 'T8', 'RightUpperLeg', 'RightLowerLeg', 'RightFoot',...
    'LeftUpperLeg', 'LeftLowerLeg', 'LeftFoot'};

% Headers that will contain the .sto file: these header are define by
% OpenSim-> OpenSense guideline (e.g. pelvis -> pelvis_imu)
Headers = {'pelvis_imu', 'torso_imu', 'femur_r_imu', 'tibia_r_imu', 'calcn_r_imu', ...
    'femur_l_imu', 'tibia_l_imu', 'calcn_l_imu'};

Names   = fieldnames(R.rawData);
ntr     = length(Names);
nbodies =  length(Headers);
    if ~isfolder(OutPath)
        mkdir(OutPath);
    end
    for i=1:ntr
        % get the file data
        filename = Names{i};
        dat = R.rawData.(filename);

        % pre-allocate the data matrix
        SegmentNames = fieldnames(dat.segments);
%         SensorNames = fieldnames(dat.sensors);
        nfr = size(dat.segments.(SegmentNames{1}).segmentorientation,1);
%         nfr = size(dat.sensors.(SensorNames{1}).sensorOrientation,1);
        DataMatrix = zeros(nfr,nbodies*4);

        % fill the data matrix
        for j = 1:nbodies
            ih = find(strcmp(SegmentNames,Headers_MatF{j}));
%             ih = find(strcmp(SensorNames,Headers_MatF{j}));
            or = dat.segments.(SegmentNames{ih}).segmentorientation;
%             or = dat.sensors.(SensorNames{ih}).sensorOrientation;
            DataMatrix(:,j*4-3:j*4)= or;
        end

        % get the time vector
        fr = dat.framerate;
        time=(1:nfr)./fr;

        % save the Storage file for OpenSim
        Create_IMU_Storage(fullfile(OutPath ,[filename '.sto']),nfr,nbodies,time',DataMatrix,Headers);
        disp([filename ' Saved']);
    end




