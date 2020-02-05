reps = 200;
recalc = 1;

if recalc == 1

    e_g = [-90 -30 50];
    tau_g = [1e7 2e6 7e6];
    %tau_g = [2e5 9e4 3.5e5];
    %tau_g = [2e5 9e4 3.5e5];
    K_liu = [5e-1 -3e-1 -1e-1];
    % 1/266.8 = 3.7e-3 (for tuned int)
    allplots = cell(2,reps);

    cmap = othercolor('Mrainbow',64);
    colormap(cmap);

    allplots = cell(2,reps);
    
    for i=1:reps

        v0 = -65;
        c0 = 0.01;

        %g0 = [0.05 0.01*rand(1,length(e_g)-1)];
        g0 = [0.05+0.01*rand 0.01*rand(1,length(e_g)-1)];
        %g0 = 0.01*rand(1,length(e_g))+0.02;

        [t X] = system01_determ('modified liu',1e8,[v0 c0 g0 g0],1,100,1,e_g,tau_g,K_liu);
        allplots{1,i} = t;
        allplots{2,i} = X;    
    end

    Xss = zeros(reps,length(e_g));
    Xinit = zeros(reps,length(e_g));

    for i=1:reps
        t = allplots{1,i};
        X = allplots{2,i};
        for j=1:length(e_g)
            Xss(i,j) = X(end,3+j-1);
            Xinit(i,j) = X(1,3+j-1);
        end
    end
    colours = othercolor('Mrainbow',reps);
    plotstoplot = randperm(reps);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 3D plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf;
shadowcol = [0.8 0.8 0.8];
mksz = 5;
linecol = [1 0.7 0.5];
zmin = -1e-3;

hold on;

for i=1:0
    plt = plotstoplot(i);
    t = allplots{1,plt};
    X = allplots{2,plt};
    plot3(X(:,3),X(:,4),X(:,5),'color',linecol,'linewidth',2);
end

% other views work as well
set(gca,'projection','perspective','view',[-37 22],'linewidth',1.5,'xgrid','on','ygrid','on','zgrid','on','fontsize',14);
%set(gca,'projection','perspective','view',[-26 30],'linewidth',1.5,'xgrid','on','ygrid','on','zgrid','on','fontsize',14);
%set(gca,'projection','perspective','view',[-26 26],'linewidth',1.5,'xgrid','on','ygrid','on','zgrid','on','fontsize',14);
%set(gca,'projection','perspective','view',[-18 42],'linewidth',1.5,'xgrid','on','ygrid','on','zgrid','on','fontsize',14);
xlabel('g_1 [\muS]','fontsize',16);
zlabel('g_3 [\muS]','fontsize',16);
ylabel('g_2 [\muS]','fontsize',16);
plot3(Xss(:,1),Xss(:,2),zmin*ones(reps,1),'o','color',shadowcol,'markersize',mksz,'markerfacecolor',shadowcol);
plot3(Xinit(:,1),Xinit(:,2),zmin*ones(reps,1),'o','color',shadowcol,'markersize',mksz,'markerfacecolor',shadowcol);
% so shadow is underneath
plot3(Xinit(:,1),Xinit(:,2),Xinit(:,3),'o','color',[0 0 0],'markersize',mksz+1,'markerfacecolor',colours(30,:));
plot3(Xss(:,1),Xss(:,2),Xss(:,3),'o','color',[0 0 0],'markersize',mksz+1,'markerfacecolor',colours(100,:));
axis tight;
set(gca,'zlim',[zmin 1.2e-2]);
set(gca,'xlim',[0.005 0.065]);
set(gca,'ylim',[-5e-3 0.04]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  correlation plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
Xss_sub = Xss; %- ones(reps,1)*mean(Xss,1);
axcol = [1 1 1];

[H,AX,BigAx,P] = plotmatrix(Xss_sub,'k.');
set(H,'markersize', 10);
set(H,'color', colours(100,:));
%set(AX,'color',[0.88 0.88 0.88]);
set(AX,'fontsize',18,'linewidth',1);
set(AX,'xcolor',axcol);
set(AX,'ycolor',axcol);
set(P,'facecolor',[1 1 1]);
set(P,'linewidth',2);
set(P,'edgecolor',colours(100,:));
axis tight;
sizefig wee;

figure;
Xinit_sub = Xinit; %- ones(reps,1)*mean(Xinit,1);

[H,AX,BigAx,P] = plotmatrix(Xinit_sub,'k.');
set(H,'markersize', 10);
set(H,'color', colours(30,:));
%set(AX,'color',[0.88 0.88 0.88]);
set(AX,'fontsize',18,'linewidth',1);
set(AX,'xcolor',axcol);
set(AX,'ycolor',axcol);
set(P,'facecolor',[1 1 1]);
set(P,'linewidth',2);
set(P,'edgecolor',colours(30,:));
axis tight;
sizefig wee;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% example plots og gmax evolution over time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ms2hours = 1000*60*60;
figure;
for i=1:10
    plt = plotstoplot(i);
    t = allplots{1,plt};
    X = allplots{2,plt};
    hold on;
    plot(t/ms2hours,X(:,3),'color',colours(1+19*i,:),'linewidth',2);
end
sizefig wee;
xlabel('time (hours)');
ylabel('conductance g_A (\muS)');
tidyfig;
figure;

for i=1:10
    plt = plotstoplot(i);
    t = allplots{1,plt};
    X = allplots{2,plt};
    hold on;
    plot(t/ms2hours,X(:,4),'color',colours(1+19*i,:),'linewidth',2);
end
sizefig wee;
xlabel('time (hours)');
ylabel('conductance g_B (\muS)');
tidyfig;
figure;

for i=1:10
    plt = plotstoplot(i);
    t = allplots{1,plt};
    X = allplots{2,plt};
    hold on;
    plot(t/ms2hours,X(:,5),'color',colours(1+19*i,:),'linewidth',2);
end
sizefig wee;
xlabel('time (hours)');
ylabel('conductance g_C (\muS)');
tidyfig;
