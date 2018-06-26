data = load("/home/tshu/project/Cluster2018/workflow-2/result.dat");
scatter3(data(:,1), data(:,2), data(:,3), 10, data(:,4), 'filled');
hold on;
colorbar('FontSize', 22, 'Location','southoutside');
xlabel('HT: X', 'Fontsize', 22);
ylabel('HT: Y', 'Fontsize', 22);
zlabel('SW', 'Fontsize', 22);
axis([0.9 4.1 0.9 4.1 0.8 16]);
set(gca, 'XTick', 1 : 1 : 4);
set(gca, 'YTick', 1 : 1 : 4);
set(gca, 'ZTick', 1 : 3 : 16);
set(gca, 'FontSize', 22);
set(gcf, 'position', [100 100 1000 618])
print('/home/tshu/project/Cluster2018/workflow-2/fig2.eps','-depsc')
print('/home/tshu/project/Cluster2018/workflow-2/fig2.png','-dpng')

