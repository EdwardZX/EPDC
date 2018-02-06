%ss = SegShow(rmsd,rP,20,Polar);

segs = [1,13;14,21;22,25;26,32;33,34;35,39;40,42;43,48;49,55;56,60;61,61;...
        62,63;64,67;68,69;70,71;72,75;76,76];
L = size(segs,1);
velocity = [];
polar = [];
tags = [];
diff = zeros(L,1);
alpha = zeros(L,1);
indices = zeros(L,2);
saveFolder = uigetdir();

for m = 1:1:L
    % select segs
    ss.onSegTo(segs(m,2)); ss.onSegFrom(segs(m,1));
    % get region index
    tmpIndices = ss.selectIndices;
    % save whole figure
    tmpImage = getframe(ss.getFigHandles().figure1);
    imwrite(tmpImage.cdata,fullfile(saveFolder,sprintf('%d-%d-whole.png',segs(m,1),segs(m,2))));
    % get trace
    ss.onXDataType(3); ss.onYDataType(4);
    ss.onPlotTypeSelected(1);
    tmpXY = [ss.tmpXData,ss.tmpYData];
    tmpImage = getframe(ss.getFigHandles().axes_plot);
    imwrite(tmpImage.cdata,fullfile(saveFolder,sprintf('%d-%d-trace.png',segs(m,1),segs(m,2))));
    % get polar-velocity
    ss.onXDataType(2); ss.onYDataType(1);
    ss.onPlotTypeSelected(2);
    ss.onXRange(0,90); ss.onYRange(0,0.15);
    [hf,~] = ss.onCopyFig();
    set(hf,'Color',[1,1,1],'Position',[0,0,600,560]);
    tmpImage = getframe(hf);
    imwrite(tmpImage.cdata,fullfile(saveFolder,sprintf('%d-%d-pv-1.png',segs(m,1),segs(m,2))));
    close(hf);
    ss.onPlotTypeSelected(3);
    ss.isActivePlot = 1; [hf,ha] = ss.onPlotDraw();ss.isActivePlot = 0;
    ha.RLim = [0,0.15];
    set(hf,'Color',[1,1,1],'Position',[0,0,600,560]);
    tmpImage = getframe(hf);
    imwrite(tmpImage.cdata,fullfile(saveFolder,sprintf('%d-%d-pv-2.png',segs(m,1),segs(m,2))));
    close(hf);
    tmpPolar = ss.tmpXData;
    tmpVelocity = ss.tmpYData;
    % get polar-alpha
    ss.onYDataType(6);
    ss.onPlotTypeSelected(2);
    ss.onXRange(0,90); ss.onYRange(0,2.5);
    [hf,~] = ss.onCopyFig();
    set(hf,'Color',[1,1,1],'Position',[0,0,600,560]);
    tmpImage = getframe(hf);
    imwrite(tmpImage.cdata,fullfile(saveFolder,sprintf('%d-%d-pa-1.png',segs(m,1),segs(m,2))));
    close(hf);
    ss.onPlotTypeSelected(3);
    ss.isActivePlot = 1; [hf,ha] = ss.onPlotDraw(); ss.isActivePlot = 0;
    set(hf,'Color',[1,1,1],'Position',[0,0,600,560]);
    ha.RLim = [0,2.5];
    tmpImage = getframe(hf);
    imwrite(tmpImage.cdata,fullfile(saveFolder,sprintf('%d-%d-pa-2.png',segs(m,1),segs(m,2))));
    close(hf);
    % get diff-alpha
    ss.onXDataType(5);
    ss.onPlotTypeSelected(2);
    ss.onXRange(0,0.07); ss.onYRange(0,2.5);
    [hf,~] = ss.onCopyFig();
    set(hf,'Color',[1,1,1],'Position',[0,0,600,560]);
    tmpImage = getframe(hf);
    imwrite(tmpImage.cdata,fullfile(saveFolder,sprintf('%d-%d-da.png',segs(m,1),segs(m,2))));
    close(hf);
    % store
    len = length(tmpPolar);
    velocity = [velocity;tmpVelocity];
    polar = [polar;tmpPolar];
    tags = [tags;ones(len,1)*m];
    d_al = SegShow.trace2diffAlpha(tmpXY,1);
    [diff(m),alpha(m)] = deal(d_al(1),d_al(2));
    indices(m,:) = tmpIndices;
    % print
    fprintf(1,'%d/%d has done!\n',m,L);
end

figure;
ha = axes;
boxplot(subplot(3,1,1),velocity,tags,'BoxStyle','filled','MedianStyle','target','symbol','')
boxplot(subplot(3,1,2),polar,tags,'BoxStyle','filled','Color','r','MedianStyle','target','symbol','')
plot(1:18,diff);
boxplot(subplot(3,1,2),polar,tags,'BoxStyle','filled','Color','r','MedianStyle','target','symbol','')
plot(subplot(3,1,3),1:L,diff);
plotyy(subplot(3,1,3),1:L,diff,1:L,alpha);
figure;
ha = axes;
rmsd.plotTest(ha,rmsd.velocity);
for m = 1:1:L
    line(ha,ones(2,1)*indices(m,1),[0,0.15],'Color','r','LineWidth',2,'LineStyle','--');
    line(ha,ones(2,1)*indices(m,2),[0,0.15],'Color','r','LineWidth',2,'LineStyle','--');
end

figure;
ha = axes;
rP.plotTest(ha,Polar);
for m = 1:1:L
line(ha,ones(2,1)*indices(m,1),[0,90],'Color','r','LineWidth',1,'LineStyle','--');
line(ha,ones(2,1)*indices(m,2),[0,90],'Color','r','LineWidth',1,'LineStyle','--');
end
