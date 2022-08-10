% function [time, DataMatrix, DataMatrix_acc, DataMatrix_mag] = CreateOpenSense_fun(rawData, Xsens_datafolder, OpenSense_folder, offset_sync)
%% Generat e Opensense file for kinematic analysis in OpenSim
%-----------------------------------------------------------
%% Settings

% addpath('C:\GiacomoDR\OpenSense\OpenSense_data_working\Functions_Xsens_to_OS\CPP_Projects\MexFiles');
addpath('C:\GiacomoDR\MATLAB\Functions_Xsens_to_OS');
Xsens_datafolder = pwd; 
OpenSense_folder = pwd;

% R = load(fullfile(Xsens_datafolder,['Session1-00', num2str(j),'.mat']))

for k = 1:3
    if k<10
        R = load(fullfile(Xsens_datafolder, ['Session1-00', num2str(k)] ));% insert the name of last session
    else
        R = load(fullfile(Xsens_datafolder, ['Session1-0', num2str(k)] ));% insert the name of last session
    end
    OutPath = [OpenSense_folder '\OpenSense'];

    %% Export the storage files

    % Headers = {'pelvis_imu','torso_imu','humerus_r_imu','radius_r_imu','hand_r_imu','humerus_l_imu','radius_l_imu','hand_l_imu',...
    %     'femur_r_imu','tibia_r_imu','calcn_r_imu','toes_r_imu','femur_l_imu','tibia_l_imu','calcn_l_imu','toes_l_imu'};
    % Headers_MatF = {'Pelvis','L5','RightUpperArm','RightForeArm','RightHand','LeftUpperArm','LeftForeArm','LeftHand', ...
    %     'RightUpperLeg','RightLowerLeg','RightFoot','RightToe','LeftUpperLeg','LeftLowerLeg','LeftFoot','LeftToe'};

    Headers = {'torso_imu', 'pelvis_imu','humerus_r_imu','radius_r_imu','humerus_l_imu','radius_l_imu',...
        'femur_r_imu','tibia_r_imu','calcn_r_imu','femur_l_imu','tibia_l_imu','calcn_l_imu'};

    Headers_MatF = { 'T8', 'Pelvis', 'RightUpperArm','RightForeArm','LeftUpperArm','LeftForeArm',...
        'RightUpperLeg','RightLowerLeg','RightFoot','LeftUpperLeg','LeftLowerLeg','LeftFoot'}; 

    Names   = fieldnames(R.rawData);
    ntr     = length(Names);
    nbodies =  length(Headers);
    if ~isfolder(OutPath)
        mkdir(OutPath);
    end
    %     for i=1:ntr
    %         % get the file data
    %         filename = Names{i};
    %         dat = R.rawData.(filename);
    % 
    %         % pre-allocate the data matrix
    %         SegmentNames = fieldnames(dat.segments);
    %         nfr = size(dat.segments.(SegmentNames{1}).segmentorientation,1);
    %         DataMatrix = zeros(nfr,nbodies*4);
    % 
    %         % fill the data matrix
    %         for j = 1:nbodies
    %             ih = find(strcmp(SegmentNames,Headers_MatF{j}));
    %             or = dat.segments.(SegmentNames{ih}).segmentorientation;
    %             DataMatrix(:,j*4-3:j*4)= or;
    %         end
    % 
    %         % get the time vector
    %         fr = dat.framerate;
    %         time=(1:nfr)./fr;
    % 
    %         % save the Storage file for OpenSim
    %         Create_IMU_Storage(fullfile(OutPath ,[filename '.sto']),nfr,nbodies,time',DataMatrix,Headers);
    %         disp([filename ' Saved']);
    %     end
    %%
    for i=1:ntr
        % get the file data
        filename = Names{i};
        dat = R.rawData.(filename);

        % pre-allocate the data matrix
        SensorsNames = fieldnames(dat.sensors);
        nfr = size(dat.sensors.(SensorsNames{1}).sensorOrientation,1);
        DataMatrix = zeros(nfr,nbodies*4);
        DataMatrix_acc = zeros(nfr,nbodies*3);
        DataMatrix_ang = zeros(nfr,nbodies*3);
        DataMatrix_mag = zeros(nfr,nbodies*3);

            % fill the data matrix
            for j = 1:nbodies
                ih = find(strcmp(SensorsNames, Headers_MatF{j}));
                or = dat.sensors.(SensorsNames{ih}).sensorOrientation;
                acc = dat.sensors.(SensorsNames{ih}).sensorFreeAcceleration;
    %                 ang = dat.sensors.(SensorsNames{ih}).sensorAngularVelocity;
                mag = dat.sensors.(SensorsNames{ih}).sensorMagneticField;
                DataMatrix(:,j*4-3:j*4) = or;
                DataMatrix_acc(:,j*3-2:j*3) = acc;
    %                 DataMatrix_ang(:,j*3-2:j*3) = ang;                
                DataMatrix_mag(:,j*3-2:j*3) = mag;                
            end

        % get the time vector
        fr = dat.framerate;
        time=(0:nfr-1)./fr + 0;
        if k>=10
            save( ['Session1-0', num2str(k),'_DataM'] , 'DataMatrix_acc', 'DataMatrix_mag', 'DataMatrix');
        else
            save( ['Session1-00', num2str(k),'_DataM'] , 'DataMatrix_acc', 'DataMatrix_mag', 'DataMatrix');
        end
        pause(2)
%         save the Storage file for OpenSim
        Create_IMU_Storage(fullfile(OutPath, [filename '_orientations.sto']), nfr, nbodies, time', DataMatrix, Headers);
        disp([filename ' Saved']);

    end

    %%
    %         Create_IMU_Storage(fullfile(OutPath, [filename '_acc.sto']), nfr, nbodies, time', DataMatrix_acc, Headers);
    %         Create_IMU_Storage(fullfile(OutPath, [filename '_ang.sto']), nfr, nbodies, time', DataMatrix_ang, Headers);
    %         Create_IMU_Storage(fullfile(OutPath, [filename '_mag.sto']), nfr, nbodies, time', DataMatrix_mag, Headers);



end