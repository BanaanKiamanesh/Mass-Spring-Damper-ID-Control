clear;
close all;
clc;
rng(1, "twister");
format compact;

%% Load the Model and Extract Properties
load('Controller.mat');

Sys = System.Sys;
SysDiscrete = System.SysDiscrete;
Ts = System.Ts;

% Controller Properties
Kp = System.Controller.Kp;
Ki = System.Controller.Ki;
Kd = System.Controller.Kd;

%% Genetic Algorithm Initialization

nPop = 25;                          % Population Size
MaxIt = 10;                         % Number of Iterations
nVar = 3;                           % Number of Decision Variables 

InitialCondition = [Kp, Ki, Kd];   % Set the GA Initial Condition

InitPop = rand(nPop, 3) * 0.01 + repmat(InitialCondition, nPop, 1);        % Initial Population

% GA Function Optimization Options
Opt = optimoptions(@ga, 'PopulationSize', nPop, ...
                'MaxGenerations', MaxIt, ...
                'InitialPopulation', InitPop, ...
                'OutputFcn', @GACallback);

% Run GA
[x, fval, exitflag, output, population, scores]  = ...
                ga(@(param)PIDCost(SysDiscrete, Ts, param, false), ...
                3, -eye(3), zeros(3, 1), ...
                [], [], [], [], [], Opt);

PIDCost(SysDiscrete, Ts, x, true)
