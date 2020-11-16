% CreateGLCM.m
% Written by: Ryan Au
% Function creates normalized GLCM, only considering the three non-diagonal neighbouring image voxels.
% --------------------------------------------------------------------------------------------------------------------
% Input:
%   img = image for which GLCM should be measured from. Region of interest should be segmented and unimportant voxels
%         denoated as NaN.
% --------------------------------------------------------------------------------------------------------------------
% Output:
%   normGLCM = normalized GLCM with only the three non-diagonal neighbouring image voxels considered.
% --------------------------------------------------------------------------------------------------------------------
% Notes for running:
%   1) Function written to analyze 3D images.
%   2) Backgroumd voxels will be set to something unrealistic for compuation, but will be excluded in the final GLCM.
%   3) Negative voxel values are acceptable. Function will remap all values to positive values so that indexing
%      can be satisified.

function normGLCM = CreateGLCM(img)
%% Initialization
minim = min(min(min(img)));
img = img + (abs(minim) + 1);  %remaps all voxel values so GLCM can have positive indices
minim = min(min(min(img)));
maxim = max(max(max(img)));
img(isnan(img)) = maxim + 1;  %sets background voxels to something unrealistic
img = padarray(img,[1 1 1],maxim + 1);

GLs = maxim + 1;
dimensions = size(img);
xNeighbour = zeros(GLs,GLs);
yNeighbour = zeros(GLs,GLs);
zNeighbour = zeros(GLs,GLs);

%% GLCM Creation
for X = 2:dimensions(1) - 1
    for Y = 2:dimensions(2) - 1
        for Z = 2:dimensions(3) - 1
            xNeighbour(img(X,Y,Z),img(X+1,Y,Z)) = xNeighbour(img(X,Y,Z),img(X+1,Y,Z)) + 1;
            yNeighbour(img(X,Y,Z),img(X,Y+1,Z)) = yNeighbour(img(X,Y,Z),img(X,Y+1,Z)) + 1;
            zNeighbour(img(X,Y,Z),img(X,Y,Z+1)) = zNeighbour(img(X,Y,Z),img(X,Y,Z+1)) + 1;
        end            
    end
end

% Accounts for reverse direction
xNeighbour2 = transpose(xNeighbour);
yNeighbour2 = transpose(yNeighbour);
zNeighbour2 = transpose(zNeighbour);

% Create raw GLCM
glcm = xNeighbour + yNeighbour + zNeighbour + xNeighbour2 + yNeighbour2 + zNeighbour2;

% Remove unnecessary columns and rows
glcm = glcm(minim:maxim,minim:maxim);
glcm(all(glcm == 0,2),:) = [];
glcm(:,all(glcm == 0,1)) = [];

% GLCM Normalization
normGLCM = glcm./sum(sum(sum(glcm)));