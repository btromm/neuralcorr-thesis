function [t x] = system01_determ(controller,tstop,x0,cm,tau_c,ca_target,e_g,tau_g,control_params,tinj,Iinj,tol,method)

if nargin < 10
    tinj = [0 tstop];
    Iinj = [0 0];
    method = 'nearest';
    options = odeset('RelTol',1e-6);
else
    options = odeset('RelTol',1e-6,'maxstep',tol*tstop);
end

n = length(e_g);

Tc = 1/tau_c;
Tg = zeros(1,n);
for i=1:n
    if tau_g(i)>0
        Tg(i) = 1/tau_g(i);
    else
        Tg(i) = 0;
    end
end
zm = 1/cm;

switch controller
    case 'i'
        v0 = x0(1);
        c0 = x0(2);
        g0 = x0(3:3+n-1);
        u0 = x0(3+n:3+2*n-1);
        K_I = control_params(1:n);
        
        y0 = zeros(1,2+n*2);
        
        y0(1) = v0;
        y0(2) = c0;
        y0(3:(3+n-1)) = g0';
        y0((3+n):(3+2*n-1)) = u0';
        
        Fu = @(v,c,g,u) K_I .* (c - ca_target);
        Fg = @(v,c,g,u) Tg .* (u - g);
        
        [t y] = ode15s(@(t,x) dxdt_sys1(t,x,Tc,zm,e_g,Fg,Fu,tinj,Iinj,method),[0 tstop],y0,options);
        
        v = y(:,1);
        c = y(:,2);
        g = y(:,3:(3+n-1));
        u = y(:,(3+n):(3+2*n-1));
        
        x = [v c g u];
        
    case 'i Na reg'
        v0 = x0(1);
        c0 = x0(2);
        g0 = x0(3:3+n-1);
        u0 = x0(3+n:3+2*n-1);
        K_I = control_params(1:n);
        
        y0 = zeros(1,2+n*2);
        
        y0(1) = v0;
        y0(2) = c0;
        y0(3:(3+n-1)) = g0';
        y0((3+n):(3+2*n-1)) = u0';
        
        Fu = @(v,c,g,u) K_I .* (c - ca_target) + [-1e-8 1e-8 -1e-8] .* ((g(3)*(e_g(3) - v) + 0.5*g(2)*(e_g(2) - v)) - 1.95);
        Fg = @(v,c,g,u) Tg .* (u - g);
        
        [t y] = ode15s(@(t,x) dxdt_sys1(t,x,Tc,zm,e_g,Fg,Fu,tinj,Iinj,method),[0 tstop],y0,options);
        
        v = y(:,1);
        c = y(:,2);
        g = y(:,3:(3+n-1));
        u = y(:,(3+n):(3+2*n-1));
        
        x = [v c g u];
        
    case 'lema'
        v0 = x0(1);
        c0 = x0(2);
        g0 = x0(3:3+n-1);
        G = control_params(1:n);
        delta = control_params(n+1:2*n);
        
        y0 = zeros(1,2+n*2);
        
        y0(1) = v0;
        y0(2) = c0;
        y0(3:(3+n-1)) = g0';
        
        Fu = @(v,c,g,u) G./(1 + exp((c-ca_target)./delta));
        Fg = @(v,c,g,u) Tg .* (u - g);
        
        [t y] = ode15s(@(t,x) dxdt_sys0(t,x,Tc,zm,e_g,Fg,Fu,tinj,Iinj,method),[0 tstop],y0,options);
        
        v = y(:,1);
        c = y(:,2);
        g = y(:,3:(3+n-1));

        u = zeros(length(t),n);
        for i=1:n
            if G(i)*tau_g(i) == 0
                continue;
            else
                u(:,i) = G(i)./(1+exp((c-ca_target)./delta(i)));
            end
        end

        x = [v c g u];
        
    case 'p'
        v0 = x0(1);
        c0 = x0(2);
        g0 = x0(3:3+n-1);
        K_P = control_params(1:n);
        K_inf = control_params(n+1:2*n);
        
        y0 = zeros(1,2+n*2);
        
        y0(1) = v0;
        y0(2) = c0;
        y0(3:(3+n-1)) = g0';
        
        Fu = @(v,c,g,u) K_P.*(c-ca_target) + K_inf;
        Fg = @(v,c,g,u) Tg .* (u - g);
        
        [t y] = ode15s(@(t,x) dxdt_sys0(t,x,Tc,zm,e_g,Fg,Fu,tinj,Iinj,method),[0 tstop],y0,options);
        
        v = y(:,1);
        c = y(:,2);
        g = y(:,3:(3+n-1));

        u = zeros(length(t),n);
        for i=1:n
            if K_P(i)*tau_g(i) == 0
                continue;
            else
                u(:,i) = K_P(i).*(c-ca_target) + K_inf(i);
            end
        end

        x = [v c g u];
        
    case 'liu'
        v0 = x0(1);
        c0 = x0(2);
        g0 = x0(3:3+n-1);
        K_liu = control_params(1:n);
        
        y0 = zeros(1,2+n*2);
        
        y0(1) = v0;
        y0(2) = c0;
        y0(3:(3+n-1)) = g0';
        
        Fu = @(v,c,g,u) K_liu.*(c-ca_target);
        Fg = @(v,c,g,u) Tg .* (u .* g);
        
        [t y] = ode15s(@(t,x) dxdt_sys0(t,x,Tc,zm,e_g,Fg,Fu,tinj,Iinj,method),[0 tstop],y0,options);
        
        v = y(:,1);
        c = y(:,2);
        g = y(:,3:(3+n-1));

        u = zeros(length(t),n);
        for i=1:n
            if K_liu(i)*tau_g(i) == 0
                continue;
            else
                u(:,i) = K_liu(i).*(c-ca_target);
            end
        end

        x = [v c g u];
        
    case 'lema old'
        v0 = x0(1);
        c0 = x0(2);
        g0 = x0(3:3+n-1);
        G = control_params(1:n);
        delta = control_params(n+1:2*n);
        
        y0 = zeros(1,5+n*5);
        
        y0(1) = v0;
        y0(2) = c0;
        y0(3) = Tc;
        y0(4) = zm;
        y0(5) = ca_target;
        y0(6:(6+n-1)) = g0';
        y0((6+n):(6+2*n-1)) = e_g';
        y0((6+2*n):(6+3*n-1)) = Tg';
        y0((6+3*n):(6+4*n-1)) = G';
        y0((6+4*n):(6+5*n-1)) = delta';

        [t y] = ode15s(@dxdt_LeMA_Ng,[0 tstop],y0,options);
        
        v = y(:,1);
        c = y(:,2);
        g = y(:,6:(6+n-1));
        
        u = zeros(length(t),n);
        for i=1:n
            if G(i)*tau_g(i) == 0
                continue;
            else
                u(:,i) = G(i)./(1+exp((c-ca_target)./delta(i)));
            end
        end
        
        x = [v c g u];
        
    case 'integrating liu'
        v0 = x0(1);
        c0 = x0(2);
        g0 = x0(3:3+n-1);
        u0 = x0(3+n:3+2*n-1);
        K_u = control_params;
        
        y0 = zeros(1,5+n*5);
        
        y0(1) = v0;
        y0(2) = c0;
        y0(3) = Tc;
        y0(4) = zm;
        y0(5) = ca_target;
        y0(6:(6+n-1)) = g0';
        y0((6+n):(6+2*n-1)) = u0';
        y0((6+2*n):(6+3*n-1)) = e_g';
        y0((6+3*n):(6+4*n-1)) = Tg';
        y0((6+4*n):(6+5*n-1)) = K_u';

        [t y] = ode15s(@dxdt_intliu_Ng,[0 tstop],y0,options);
        
        v = y(:,1);
        c = y(:,2);
        g = y(:,6:(6+n-1));
        u = y(:,(6+n):(6+2*n-1));
        
        x = [v c g u];
        
    case 'modified liu'
        v0 = x0(1);
        c0 = x0(2);
        g0 = x0(3:3+n-1);
        K_liu = control_params(1:n);
        
        y0 = zeros(1,5+n*5);
        
        y0(1) = v0;
        y0(2) = c0;
        y0(3) = Tc;
        y0(4) = zm;
        y0(5) = ca_target;
        y0(6:(6+n-1)) = g0';
        y0((6+n):(6+2*n-1)) = e_g';
        y0((6+2*n):(6+3*n-1)) = Tg';
        y0((6+3*n):(6+4*n-1)) = K_liu';
        
        [t y] = ode15s(@dxdt_modliu_Ng,[0 tstop],y0,options);
        
        v = y(:,1);
        c = y(:,2);
        g = y(:,6:(6+n-1));
        
        u = zeros(length(t),n);
        for i=1:n
            if K_liu(i)*tau_g(i) == 0
                continue;
            else
                u(:,i) = (c-ca_target).*(K_liu(i)*g(:,i));
            end
        end
        
        x = [v c g u];
end

end
