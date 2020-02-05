reps = 100;
recalc = 0;

if recalc == 1
    [Xinit Xss1] = scatter_sys0_liu([1 1 1],reps);
    [Xinit Xss2] = scatter_sys0_liu([1 -1 1],reps);
    [Xinit Xss3] = scatter_sys0_liu([2 0.5 1],reps);
end

colours = othercolor('Mrainbow',reps);

shadowcol = [0.8 0.8 0.8];
mksz = 4;
linecol = [1 0.7 0.5];
zmin = -2.5e-3;
edgecol = [0.1 0.1 0.1];
clf;
axcol = [1 1 1];
hold on;

% other views work as well
set(gca,'projection','perspective','view',[-215 20],'linewidth',1.5,'xgrid','on','ygrid','on','zgrid','on','fontsize',14);
%set(gca,'projection','perspective','view',[-26 30],'linewidth',1.5,'xgrid','on','ygrid','on','zgrid','on','fontsize',14);
%set(gca,'projection','perspective','view',[-26 26],'linewidth',1.5,'xgrid','on','ygrid','on','zgrid','on','fontsize',14);
%set(gca,'projection','perspective','view',[-18 42],'linewidth',1.5,'xgrid','on','ygrid','on','zgrid','on','fontsize',14);
xlabel('g_1 [\muS]','fontsize',16);
zlabel('g_3 [\muS]','fontsize',16);
ylabel('g_2 [\muS]','fontsize',16);
h1 = plot3(Xss1(:,1),Xss1(:,2),zmin*ones(reps,1),'o','markeredgecolor','none','markersize',mksz,'markerfacecolor',shadowcol);
h2 = plot3(Xinit(:,1),Xinit(:,2),zmin*ones(reps,1),'o','markeredgecolor','none','markersize',mksz,'markerfacecolor',shadowcol);
h3 = plot3(Xss2(:,1),Xss2(:,2),zmin*ones(reps,1),'o','markeredgecolor','none','markersize',mksz,'markerfacecolor',shadowcol);
h4 = plot3(Xss3(:,1),Xss3(:,2),zmin*ones(reps,1),'o','markeredgecolor','none','markersize',mksz,'markerfacecolor',shadowcol);
% so shadow is underneath
h5 = plot3(Xinit(:,1),Xinit(:,2),Xinit(:,3),'o','markeredgecolor',edgecol,'markersize',mksz+1,'markerfacecolor',colours(floor(reps/6),:));
h6 = plot3(Xss1(:,1),Xss1(:,2),Xss1(:,3),'o','markeredgecolor',edgecol,'markersize',mksz+1,'markerfacecolor',colours(floor(reps/2),:));
h7 = plot3(Xss2(:,1),Xss2(:,2),Xss2(:,3),'o','markeredgecolor',edgecol,'markersize',mksz+1,'markerfacecolor',colours(floor(reps*0.9),:));
h8 = plot3(Xss3(:,1),Xss3(:,2),Xss3(:,3),'o','markeredgecolor',edgecol,'markersize',mksz+1,'markerfacecolor',colours(floor(reps*0.7),:));
uistack(h8,'down',4);
uistack(h7,'down',4);
uistack(h6,'down',4);
uistack(h5,'down',4);
refresh;
axis tight;
axis equal;
set(gca,'zlim',[zmin 1.7e-2]);
set(gca,'xlim',[-5e-3 6.5e-2]);
set(gca,'ylim',[-5e-3 4e-2]);
sizefig wee;
% correlation plot


figure;
Xinit_sub = Xinit; %- ones(reps,1)*mean(Xinit,1);

[H,AX,BigAx,P] = plotmatrix(Xinit_sub,'k.');
set(H,'markersize', 10);
set(H,'color', colours(floor(reps/6),:));
%set(AX,'color',[0.88 0.88 0.88]);
set(AX,'fontsize',18,'linewidth',1);
set(AX,'xcolor',axcol);
set(AX,'ycolor',axcol);
set(P,'facecolor',[1 1 1]);
set(P,'linewidth',2);
set(P,'edgecolor',colours(floor(reps/6),:));
axis tight;
sizefig wee;

figure;
Xss_sub = Xss1; %- ones(reps,1)*mean(Xss,1);
axcol = [1 1 1];

[H,AX,BigAx,P] = plotmatrix(Xss_sub,'k.');
set(H,'markersize', 10);
set(H,'color', colours(floor(reps/2),:));
%set(AX,'color',[0.88 0.88 0.88]);
set(AX,'fontsize',18,'linewidth',1);
set(AX,'xcolor',axcol);
set(AX,'ycolor',axcol);
set(P,'facecolor',[1 1 1]);
set(P,'linewidth',2);
set(P,'edgecolor',colours(floor(reps/2),:));
axis tight;
sizefig wee;

figure;
Xss_sub = Xss2; %- ones(reps,1)*mean(Xss,1);
axcol = [1 1 1];

[H,AX,BigAx,P] = plotmatrix(Xss_sub,'k.');
set(H,'markersize', 10);
set(H,'color', colours(floor(reps*0.9),:));
%set(AX,'color',[0.88 0.88 0.88]);
set(AX,'fontsize',18,'linewidth',1);
set(AX,'xcolor',axcol);
set(AX,'ycolor',axcol);
set(P,'facecolor',[1 1 1]);
set(P,'linewidth',2);
set(P,'edgecolor',colours(floor(reps*0.9),:));
axis tight;
sizefig wee;

figure;
Xss_sub = Xss3; %- ones(reps,1)*mean(Xss,1);
axcol = [1 1 1];

[H,AX,BigAx,P] = plotmatrix(Xss_sub,'k.');
set(H,'markersize', 10);
set(H,'color', colours(floor(reps*0.7),:));
%set(AX,'color',[0.88 0.88 0.88]);
set(AX,'fontsize',18,'linewidth',1);
set(AX,'xcolor',axcol);
set(AX,'ycolor',axcol);
set(P,'facecolor',[1 1 1]);
set(P,'linewidth',2);
set(P,'edgecolor',colours(floor(reps*0.7),:));
axis tight;
sizefig wee;

