reps = 20;
recalc = 1;
%mult = [1 -1 1];
%mult = [2 0.5 1];
mult = [1 1 1];
close all;

if recalc == 1

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

        g0 = [0.05+0.01*rand 0.01*rand(1,length(e_g)-1)];

        [t X] = system01_determ('modified liu',1e8,[v0 c0 g0 g0],1,100,1,e_g,tau_g,K_liu);
        allplots{1,i} = t;
        allplots{2,i} = X;    
    end

    colours = othercolor('Mrainbow',220);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% example plots og gmax evolution over time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ms2hours = 1000*60*60;
figure;
for i=1:10
    t = allplots{1,i};
    X = allplots{2,i};
    hold on;
    plot(t/ms2hours,1000*X(:,3),'color',colours(1+19*i,:),'linewidth',2);
end
sizefig(300,200);
xlabel('time (hours)');
ylabel('g_A (nS)');
set(gca,'xlim',[0,24]);
tidyfig;
figure;

for i=1:10
    t = allplots{1,i};
    X = allplots{2,i};
    hold on;
    plot(t/ms2hours,1000*X(:,4),'color',colours(1+19*i,:),'linewidth',2);
end
sizefig(300,200);
xlabel('time (hours)');
ylabel('g_B (nS)');
set(gca,'xlim',[0,24]);
tidyfig;
figure;

for i=1:10
    t = allplots{1,i};
    X = allplots{2,i};
    hold on;
    plot(t/ms2hours,1000*X(:,5),'color',colours(1+19*i,:),'linewidth',2);
end
sizefig(300,200);
xlabel('time (hours)');
ylabel('g_C (nS)');
set(gca,'xlim',[0,24]);
tidyfig;

figure;
for i=1:10
    t = allplots{1,i};
    X = allplots{2,i};
    hold on;
    plot(t/ms2hours,X(:,2),'color',colours(1+19*i,:),'linewidth',2);
end
plot(t/ms2hours,0*X(:,2)+1,'r:');
sizefig(300,200);
xlabel('time (hours)');
ylabel('[Ca^{2+}] (\muM)');
set(gca,'ylim',[0,1.4]);
set(gca,'xlim',[0,24]);
tidyfig;

figure;
for i=1:10
    t = allplots{1,i};
    X = allplots{2,i};
    hold on;
    plot(t/ms2hours,X(:,1),'color',colours(1+19*i,:),'linewidth',2);
end
sizefig(300,200);
xlabel('time (hours)');
ylabel('V_{m} (mV)');
set(gca,'xlim',[0,24]);
tidyfig;
