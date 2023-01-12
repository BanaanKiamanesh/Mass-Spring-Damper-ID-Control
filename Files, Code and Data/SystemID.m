clear;
close all;
clc;
format compact;
rng(1, 'twister');

%% System Parameter Declaration / Sys Continous Time Representation

% Mass Spring Damper System Parameters
J = 0.01;               % Damper Const
M = 1;                  % Mass Const
K = 0.07;               % Spring Const

s = tf('s');
Sys = (1/M) / (s^2 + J/M * s + K/M);

% Check System and Specify the Sampling Time
step(Sys); grid on

tmp = findobj(gcf, 'type', 'figure');
set(tmp, 'Name', "Continuous System Step Responce");

tmp = findobj(gcf, 'type', 'line');
set(tmp, 'linewidth', 2);

Ts = 0.4;                       % Sampling Time = 0.1 * Rise Time

Sys_d = c2d(Sys, Ts);           % Discretize System

% Discretized System:
%       y(n + 2) = 1.985 * y(n + 1) - 0.996   * y(n)
%              + 0.07982 * u(n + 1) + 0.07971 * u(n)

%% Generate Rand Gaussian Signal as Input and Eval Sys

NoiseVariance = 1e-4;           % Artificial Noise Variance

t = 0: Ts: 100;                 % Discretized Time Axis (Sampling Interval)
N = numel(t);                   % Number of Samples
u = idinput(N, 'rgs');          % (rgs) ==> Random Gaussian Signal

% Evaluate System for a Given Input Signal
% + Add Some Noise
y = lsim(Sys, u, t) + sqrt(NoiseVariance) * randn(N, 1);

%% Test Plotting

Fig1 = figure("Name", "Test System Responce Plot");
Fig1.Color = [1, 1, 1];
plot(t, u, t, y, 'LineWidth', 3); grid on

xlabel('time (sec)', 'FontSize', 14 ,'FontWeight', 'Bold');
ylabel('Amp', 'FontSize', 14, 'FontWeight', 'Bold');
title('System Identification Data', 'FontSize', 14, 'FontWeight', 'Bold');
legend('u', 'y', 'FontSize', 14, 'FontWeight', 'Bold');
Fig1 = gca;
Fig1.FontSize = 14;
Fig1.FontWeight = 'B';

%% Test System Identification x = H * theta

% Make the X(Measurement) and H(Observation) Matrices
x = zeros(N - 2, 1);
H = zeros(N - 2, 4);

for n = 1: N - 2
    x(n) = y(n + 2);
    H(n, :) = [y(n + 1), y(n), u(n + 1), u(n)];
end

Theta = H \ x;
EstimatedSys = tf(Theta(3 : 4)', [1 -Theta(1 : 2)'], Ts)


%% Statistical Analysis of the Process

M = 10000;              % Number of Realizations
Theta = zeros(4, M);    % Parameter Matrix

for k = 1 : M

    % Generate Random Gaussian Input
    u = idinput(N , 'rgs');

    % Evaluate System for Given Input Signal
    y = lsim(Sys , u  , t) + sqrt(NoiseVariance) * randn(N , 1);

    % Create Observation and Measurement Matrices
    x = zeros(N - 2, 1);
    H = zeros(N - 2, 4);

    for n = 1 : N - 2
        x(n) = y(n+2);
        H(n, :) = [y(n+1), y(n), u(n+1), u(n)];
    end

    % Evaluate Theta_i
    Theta(:, k) = H\x;
end


%% Statistical Evaluation: Histogram Plotting

Fig2 = figure("Name", "Estimation Properties");
Fig2.Color = [1, 1, 1];

for i = 1:size(Theta, 1)

    subplot(2, 2, i);
    histogram(Theta(i, :), 100, "Normalization", "count");
    grid minor;

    xlabel('Count' , 'FontSize' , 14 , 'FontWeight' , 'Bold') ;
    ylabel('Frequency' , 'FontSize' , 14 , 'FontWeight' , 'Bold') ;

    title(['\mu: ', num2str(mean(Theta(i, :))), ...
        '   \sigma: ', num2str(var(Theta(i, :)))] , ...
        'FontSize' , 12 , 'FontWeight' , 'Bold') ;

    legend(['\theta_', num2str(i)], 'FontSize' , 14 , 'FontWeight' , 'Bold') ;

    Fig2 = gca ;
    Fig2.FontSize = 14 ;
    Fig2.FontWeight = 'B' ;
end


%% Final Estimated System

% ThetaHat = mean(Theta, 2);        % Simple Solution

% Out of Histograms:
% for Noise Variance of: 1e-6
% ThetaHat = [1.9849
%             -0.9960
%             0.0797
%             0.0800];

% for Noise Variance of: 1e-2
% ThetaHat = [1.9695
%             -0.9815
%             0.0958
%             0.0892];

% for Noise Variance of: 1e-4
ThetaHat = [1.9845
            -0.9957
            0.0797
            0.0803];

EstimatedSysFinal = tf(ThetaHat(3 : 4)', ...
                        [1 -ThetaHat(1 : 2)'], ...
                        Ts);

%% Plot the Identified System Along with the Estimated System

Fig3 = figure("Name", "Estimated vs Original");
Fig3.Color = [1, 1, 1];

step(Sys)
tmp = findobj(gcf, 'type', 'line');
set(tmp, 'linewidth', 3);

hold on
step(EstimatedSysFinal)
tmp = findobj(gcf, 'type', 'line');
set(tmp, 'linewidth', 3);

legend(["Real Continuous System", "Estimated System"])

%% Save Results

System.Sys = Sys;
System.SysDiscrete = Sys_d;
System.ThetaHat = ThetaHat;
System.EstimatedSystem = EstimatedSysFinal;
System.Ts = Ts;

save EstimatedSystem.mat System
clear;
