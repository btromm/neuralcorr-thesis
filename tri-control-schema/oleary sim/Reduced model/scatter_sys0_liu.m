function [Xinit Xss] = scatter_sys0_liu(mult,reps)
    
    e_g = [-90 -30 50];
    tau_g = [1e7 2e6 7e6];
    %tau_g = [2e5 9e4 3.5e5];
    %tau_g = [2e5 9e4 3.5e5];
    K_liu = [5e-1 -3e-1 -1e-1];
    K_liu = K_liu.*mult;
    
    allplots = cell(2,reps);
    
    for i=1:reps

        v0 = -65;
        c0 = 0.01;

        %g0 = [0.05 0.01*rand(1,length(e_g)-1)];
        g0 = [0.05+0.01*rand 0.01*rand(1,length(e_g)-1)];
        %g0 = 0.01*rand(1,length(e_g))+0.02;

        [t X] = system01_determ('modified liu',1e8,[v0 c0 g0 g0],1,100,1,e_g,tau_g,K_liu);
        %allplots{1,i} = t;
        allplots{2,i} = X;    
    end

    Xss = zeros(reps,length(e_g));
    Xinit = zeros(reps,length(e_g));

    for i=1:reps
        %t = allplots{1,i};
        X = allplots{2,i};
        for j=1:length(e_g)
            Xss(i,j) = X(end,3+j-1);
            Xinit(i,j) = X(1,3+j-1);
        end
    end
end
