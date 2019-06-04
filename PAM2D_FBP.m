clear all, close all, clc;

% load the initial pressure distribution from an image and scale
data = load('data/vessel_2D_(DRIVE)/Vascular_set_c0_inhomogeneous_new_fixed_mu.mat');

padsize = [200,200];
data.Train_H = padarray(data.Train_H, padsize,'both');
data.Test_H = padarray(data.Test_H, padsize,'both');

% create the computational grid
PML_size = 20;              % size of the PML in grid points

N = size(data.Train_H);

Nx = N(1);       % number of grid points in the x (row) direction
Ny = N(2);       % number of grid points in the y (column) direction
x = 10e-3;                      % total grid size [m]
y = 10e-3;                      % total grid size [m]
dx = x / Nx;                    % grid point spacing in the x direction [m]
dy = y / Ny;                    % grid point spacing in the y direction [m]
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% define a Cartesian sensor mask of a centered circle with 50 sensor elements
sensor_radius = 4e-3; % [m]
sensor_angle = 2*pi;        % [rad]
sensor_pos = [0, 0];        % [m]
num_sensor_points = 64;
sensor.mask = makeCartCircle(sensor_radius, num_sensor_points, sensor_pos, sensor_angle);
sensor.frequency_response = [6.25e6,80];
%sensor.directivity_angle
%sensor.directivity_size

% source.p0 = data.Train_H(:,:,100);
% show_result(source.p0,source.p0,kgrid,sensor.mask)

%% -------------------------------------------- %%

% take an image
source.p0 = data.Train_H(:,:,100);

% define the medium properties
medium.sound_speed = 1500*ones(Nx, Ny);             % [m/s]
medium.sound_speed(source.p0>0.02) = 1600;          % [m/s]
medium.density = 1040*ones(Nx,Ny);                  % [kg/m^3]

% run the simulation
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor,'PMLInside',false);


%% -------------------------------------------- %%

% reset the initial pressure
p0_orig = source.p0;
source.p0 = 0;

% add noise to the recorded sensor data
signal_to_noise_ratio = 40;	% [dB]
sensor_data = addNoise(sensor_data, signal_to_noise_ratio, 'peak');

% CREATE NEW GRID !!!

% assign the time reversal data
sensor.time_reversal_boundary_data = sensor_data;

% run the time reversal reconstruction
p0_recon = kspaceFirstOrder2D(kgrid, medium, source, sensor,'PMLInside',false); 

% visualize
show_result(p0_recon,p0_orig,kgrid,sensor.mask)

function [] = show_result(p0_recon,p0_orig,kgrid,cart_sensor_mask)
figure;

subplot(1,2,1);
imagesc(cart2grid(kgrid, cart_sensor_mask)+p0_orig, [-1, 1]);
%hold on;
%imagesc(p0_orig, [-1, 1]);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
title('Original image');
axis image;
colormap(getColorMap);
%hold off; 

subplot(1,2,2);
imagesc(p0_recon, [-1, 1]);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
title('Reconstructed image');
axis image;
colormap(getColorMap);
end

