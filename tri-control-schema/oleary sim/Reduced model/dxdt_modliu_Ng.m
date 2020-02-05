% K Tc zm g2 e2 e1 cs Tg
function y = dxdt_modliu_Ng(t,x)

    N = length(x) - 5;
    n = N/5;

    v = x(1);
    c = x(2);
    Tc = x(3);
    zm = x(4);
    cs = x(5);
    g = x(6:(6+n-1));
    eg = x((6+n):(6+2*n-1));
    Tg = x((6+2*n):(6+3*n-1));
    K_liu = x((6+3*n):(6+4*n-1));

    c_dot = Tc * (109.2*exp(0.08*v) - c);   %ca dynamics
    v_dot = zm * dot(g,(eg - v));           %membrane eqn
    u = (c-cs)*K_liu;
    g_dot = Tg .* (u .* g);                  %conductance regulation
    
    y = zeros(length(x),1);
    y(1) = v_dot;
    y(2) = c_dot;
    y(6:(6+n-1)) = g_dot;
end