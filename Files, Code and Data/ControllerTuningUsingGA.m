clear;
close all;
clc;
rng(1, "twister");
format compact;

%% Loading System
load('EstimatedSystem.mat')

Sys = System.SysDiscrete;
Ts = System.Ts;


%% Genetic Algorithm Initialization

nPop = 25;                          % Population Size
MaxIt = 10;                         % Number of Iterations
nVar = 3;                           % Number of Decision Variables

InitPop = rand(nPop, 3) * 2;        % Initial Population

% GA Function Optimization Options
Opt = optimoptions(@ga, 'PopulationSize', nPop, ...
    'MaxGenerations', MaxIt, ...
    'InitialPopulation', InitPop, ...
    'OutputFcn', @GACallback);

% Run GA
[x, fval, exitflag, output, population, scores]  = ...
    ga(@(param)PIDCost(Sys, Ts, param, false), ...
    3, -eye(3), zeros(3, 1), ...
    [], [], [], [], [], Opt);

% Plot Best Solution Ever Found
Fig1 = figure("Name", "Best Solution Found!");
Fig1.Color = [1, 1, 1];
PIDCost(Sys, Ts, x, true)


%% Visualization
load history.mat

SortedCost = zeros(size(Cost));

for k = 1: MaxIt
    SortedCost(:, k) = sort(Cost(:, k));
end

% Plot Dominence Trend by Iteration Progession
Fig2 = figure("Name", "Dominance Hierarchy");
Fig2.Color = [1, 1, 1];

imagesc(log(SortedCost(:, 1:MaxIt)))
colorbar
set(gcf, 'Position', [100, 100, 600, 300])
set(gcf,'PaperPositionMode','auto')

%% Scatter Plot the Evaluated Points in the Search Space

Fig3 = figure("Name", "3D Scatter Plot");
Fig3.Color = [1, 1, 1];

hold on
grid on
axis equal

for k = 1: MaxIt
    for j=1:nPop
        scatter3(Hist(j, 1, k), Hist(j, 2, k), Hist(j, 3, k), 100, ...
            [(MaxIt - k) / MaxIt, 0.25, k / MaxIt], ...
            'filled');
    end
end

[B, I] = sort(Cost(:, MaxIt));
scatter3(Hist(I(1), 1, MaxIt), Hist(I(1), 2, MaxIt), ...
    Hist(I(1), 3, MaxIt), 600, [0, 0, 0], 'filled');

view(69, 24)
box on
title("Controller Gain Search Space")
xlabel('P')
ylabel('I')
zlabel('D')
set(gcf, 'Position', [100, 100, 350, 250])
set(gcf, 'PaperPositionMode', 'auto')
