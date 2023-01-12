function  [state, options, optchanged] = GACallback(options, state, flag)

    persistent Hist
    persistent Cost
    optchanged = false;

    switch flag
        case 'init'
            Hist(:, :, 1) = state.Population;
            Cost(:, 1) = state.Score;
        
        case {'iter', 'interrupt'}
            StateSize = size(Hist, 3);
            Hist(:, :, StateSize + 1) = state.Population;
            Cost(:, StateSize + 1)    = state.Score;
        
        case 'done'
            StateSize = size(Hist, 3);
            Hist(:, :, StateSize + 1) = state.Population;
            Cost(:, StateSize + 1)    = state.Score;
            save History.mat Hist Cost
    end
end
