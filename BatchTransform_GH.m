%% Read en Save data structs Xsens
%%%%% This script loads the Xsens data from mvnx files. These files are
%%%%% loaded from a patient directory, and the resulting struct is saved in
%%%%% that same directory.

clear; close all; clc;

% point to the datafoldern where you are working
datafolder = 'C:\GiacomoDR\OpenSense\CO_p3_walk\Xsens_data_processing';

% name of the .mvnx file that you want to convert in .mat format
files = dir(fullfile(datafolder,'walk-001.mvnx'));
% Define save name / number
InitialPath = pwd;
cd(datafolder);
directory = datafolder;                         % dir = current directory
div = strfind(directory, '\');          % div = divider of directory (\)
ppId = directory(div(4)+1:end);         % participant name / number / id

% add path with TBM software tools
addpath(genpath('C:\GiacomoDR\OpenSense\DataTransform_Xsens_to_OS\Functions'));

%% Creating the data struct
    for id= 1:numel(files)
        [~,name, ~] = fileparts(files(id).name);
        [fileName] = regexprep(name, '-', '_');
        fileList{id,1} = fileName;

        % Displaying which file is beeing analyzed
        disp(['Analyzing file: ' fileName '....']);
        [tree] = load_mvnx(files(id).name);
        rawData.(fileName).suitLabel = tree.subject.label;
        rawData.(fileName).framerate = tree.subject.frameRate;
        rawData.(fileName).segmentcount = tree.subject.segmentCount;
        rawData.(fileName).originalFilename = tree.subject.originalFilename;

% define the sensor locations
        for i=1:numel(tree.subject.sensors.sensor)
            sensorLocation{1,i} = tree.subject.sensors.sensor(i).label;
        end

% define the segmentNames
        for i=1:numel(tree.subject.segments.segment)
            segmentNames{1,i} = tree.subject.segments.segment(i).label;
        end

% define the jointNames
        for i=1:numel(tree.subject.joints.joint)
            jointNames{1,i} = tree.subject.joints.joint(i).label;
        end
    
   
        %% seperating the idenentity, t-pose and n-pose orientation and position data
        % identity
        rawData.(fileName).staticData.identity.orientation = tree.subject.frames.frame(1).orientation;
        rawData.(fileName).staticData.identity.position = tree.subject.frames.frame(1).position;
        % t-pose
        rawData.(fileName).staticData.tpose.orientation = tree.subject.frames.frame(2).orientation;
        rawData.(fileName).staticData.tpose.position = tree.subject.frames.frame(2).position;
        % t-pose-isb
        rawData.(fileName).staticData.tpose_isb.orientation = tree.subject.frames.frame(3).orientation;
        rawData.(fileName).staticData.tpose_isb.position = tree.subject.frames.frame(3).position;

        tree.subject.frames.frame(1:3) = [];
    
        % restructuring the segment data
        for i = 1:numel(tree.subject.frames.frame)
            for sn = 1:numel(segmentNames)
                s2=sn * 3;
                s1=(sn * 3)-2;
                rawData.(fileName).segments.(segmentNames{sn}).segmentPosition(i,:) = tree.subject.frames.frame(i).position(s1:s2);
                rawData.(fileName).segments.(segmentNames{sn}).segmentVelocity(i,:) = tree.subject.frames.frame(i).velocity(s1:s2);
                rawData.(fileName).segments.(segmentNames{sn}).segmentAcceleration(i,:) = tree.subject.frames.frame(i).acceleration(s1:s2);
                rawData.(fileName).segments.(segmentNames{sn}).segmentorientation(i,:) = tree.subject.frames.frame(i).orientation(sn*4-3:sn*4);
                rawData.(fileName).segments.(segmentNames{sn}).segmentAngVelocity(i,:) = tree.subject.frames.frame(i).angularVelocity(s1:s2);
                rawData.(fileName).segments.(segmentNames{sn}).segmentAngAcceleration(i,:) = tree.subject.frames.frame(i).angularAcceleration(s1:s2);
            end
        end
    
        % restructuring the joint data
        for i = 1:numel(tree.subject.frames.frame)
            for jn = 1:numel(jointNames)
                s2 = jn*3;
                s1 = (jn*3)-2;
                rawData.(fileName).joints.(jointNames{jn}).jointAngle(i,:) = tree.subject.frames.frame(i).jointAngle(s1:s2);
                rawData.(fileName).joints.(jointNames{jn}).jointAngleXZY(i,:) = tree.subject.frames.frame(i).jointAngle(s1:s2);
            end
        end
    
    %restructuring the sensor data
        for i = 1: numel(tree.subject.frames.frame)
            for sl = 1:numel(sensorLocation)
                s2 = sl * 3;
                s1 = (sl *3) -2;
                rawData.(fileName).sensors.(sensorLocation{sl}).sensorAcceleration(i,:) = tree.subject.frames.frame(i).sensorAcceleration(s1:s2);
                rawData.(fileName).sensors.(sensorLocation{sl}).sensorOrientation(i,:) = tree.subject.frames.frame(i).sensorOrientation(s1:s2);
                rawData.(fileName).sensors.(sensorLocation{sl}).sensorMagneticField(i,:) = tree.subject.frames.frame(i).sensorMagneticField(s1:s2);
            end
        end

%     end

% set the name of your .mat file
save('rawData_CO_p3_walk_002')

cd(InitialPath);

end