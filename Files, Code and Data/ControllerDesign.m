clear;
close all;
clc;

%% Load the Model and Extract Properties
load('EstimatedSystem.mat')

EstimatedSys = System.EstimatedSystem;
SysDiscrete = System.SysDiscrete;
Ts = System.Ts;
Sys = System.Sys;

%% Design and Tune Controller Manually

FirstTime = true;

while true

    if FirstTime
        % Open a Question Dialog Box to Ask for PID Gains
        answer = questdlg('Wanna Tune the Controller With MATLAB or Manually?', ...
            'Controller Tune', 'MATLAB', 'Manual', 'Cancel', 'Cancel');

        FirstTime = false;
    end

    if strcmp(answer, 'MATLAB')
        %% Design and Tune a PID Cotroller with Control ToolBox
        [C_pid, info] = pidtune(EstimatedSys, 'PID');

        % Adding Controller to the Discretized System
        T = feedback(C_pid * SysDiscrete, 1);

        % Get the Step Responce of The System
        Fig = figure("Name", "Step Responce Comparison");
        Fig.Color = [1, 1, 1];

        % Check the Step Responce
        step(T)
        tmp = findobj(gcf, 'type', 'line');
        set(tmp, 'linewidth', 3);

        % Extract PID Gains Outta the C_pid Object
        Kp = C_pid.Kp;
        Ki = C_pid.Ki;
        Kd = C_pid.Kd;

        % Store Tuning Type
        TuneType = "Matlab Control Toolbox";

        break

    elseif strcmp(answer, 'Manual')
        %% Setup Dialog Box and Get The Input

        % Open an Input Box to Get the PID Gains
        Prompt = {'Kp:', 'Ki:', 'Kd:'};
        Title = 'Manual Gain Tuner';
        Dims = [1, 1, 1];

        try
            DefaultAnswer = {num2str(Kp), num2str(Ki), num2str(Kd)};
        catch
            DefaultAnswer = {'0', '0', '0'};
        end

        in = inputdlg(Prompt, Title, Dims, DefaultAnswer);

        % Read Input and Turn it into Double Values
        Kp = str2double(in{1});
        Ki = str2double(in{2});
        Kd = str2double(in{3});

        % Store Tuning Type
        TuneType = "Manual";

        %% Design The Controller and Apply to the System

        % Sys: Plant Transfer Function
        % K  : PID Controller Transfer Function
        % T  : Closed-Loop Transfer Function [T = G*K/(1+G*K)]

        K = pid(Kp, Ki, Kd, 'Ts', Ts);
        T = feedback(K*SysDiscrete, 1);

        % Display the System Properties
        clc; stepinfo(T);

        % Check the Step Responce
        step(T)
        tmp = findobj(gcf, 'type', 'line');
        set(tmp, 'linewidth', 2);

        %% Ask to See Whether to Continue or Break
        % Open a Question Dialog Box
        answer2 = questdlg('Wanna reTune it?', 'Manual PID Tuner', 'Yes', 'No', 'No');

        if strcmp(answer2, 'Yes')
            continue;

        elseif strcmp(answer2, 'No')
            break;
        end

    else
        break
    end
end

%% Store the End Results

try
    System.Controller.Kp = Kp;
    System.Controller.Ki = Ki;
    System.Controller.Kd = Kd;
    System.Controller.TuneType = TuneType;

    save Controller.mat System

    disp("Controller Parameter are Saved Into 'Controller.mat'")

catch
    disp("Exiting the Program With no Controller Designed!");
end
