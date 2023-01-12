function J = PIDCost(G, Ts, Params, PlotStep)

    %   G: Plant Transfer Function
    %   K: PID Controller Transfer Function
    %   T: Closed-Loop Transfer Fuction
    %   K: Controller Gains
    %      All elements of K are normalized ==> [-1, 1]
    %   Ts: Sampling Time

    Kp = Params(1);
    Ki = Params(2);
    Kd = Params(3);

    % Create The System
    K = pid(Kp, Ki, Kd, "Ts", Ts);
    T = feedback(series(K, G), 1);

    % Analyze the System for Properties
    StepInfo = stepinfo(T);
    OSPercent = StepInfo.Overshoot;
    SettlingTime = StepInfo.SettlingTime;

    MaxRealPole = -min(max(real(pole(T))), 0);
    StabilityIdx =  1 / (MaxRealPole + eps);

    w1 = 0.25;
    w2 = 1.2;
    w3 = 1;


    J = w1 * OSPercent + w2 * SettlingTime;% + w3 * StabilityIdx;

    if PlotStep
        step(T)
        h = findobj(gcf, 'type', 'line');
        set(h, 'linewidth', 3);
        drawnow
    end
end
