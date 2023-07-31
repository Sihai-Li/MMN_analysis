clear all; close all;
clc;

% beh = mlread('D:\Uchi_data\Stan_Nev\Stan\2022_0609_SALINE\control\20220609_stanton_mem_saccade_pseudo.bhv2')
% save('D:\Uchi_data\Stan_Nev\Stan\2022_0609_SALINE\control.mat','beh')

monkey = "Stan";
date = "2022_0607";
filename1 = '20220607_stanton_mem_saccade_pseudo_control.mat';
filename2 = '20220607_stanton_mem_saccade_pseudo_saline.mat';
% output_dict =append( "D:\Uchi_data\Stan_Nev\",monkey,"\",date, "\", phase, "\");


[x_endall1, y_endall1, condition1, RT1, meanx1, meany1] = Find_SaccadeEnd_function(filename1); %calculate saccadic endpoint and RT for file 1
[x_endall2, y_endall2, condition2, RT2, meanx2, meany2] = Find_SaccadeEnd_function(filename2); %calculate saccadic endpoint and RT for file 2

h = figure(1); %a blank figure lol!
% hold on;
% for j = 1:length(x_endall)
%     a = ntr(j);
%     color_number = beh(ntr(j)).Condition;
%     c = color_pallet{color_number}/255
%
%     %     scatter(x_endall(j),y_endall(j), [color_pallet{color_number}/255],'filled');
%     scatter(x_endall(j),y_endall(j),'filled');
% end

%%plot saccadic endpoint
subplot(1,2,1);
hold on;
scatter(x_endall1,y_endall1,'b');
scatter(x_endall2,y_endall2,'r');
% scatter(meanx1, meany1, '*','b');
% scatter(meanx2, meany2, '*','r');
xlim([-10 10]);
ylim([-10 10]);
title('Saccadic endpoints')

%%plot distribution of RT
subplot(1,2,2);
histogram(RT1,20,'FaceColor','b');
hold on;
histogram(RT2,20,'FaceColor','r');
title("Distribution of RT");
line([nanmean(RT1) nanmean(RT1)],[0 50],'Color','b','LineStyle','--' );
line([nanmean(RT2) nanmean(RT2)],[0 50],'Color','r','LineStyle','--' );
legend("control","inactivation"); %legend("control","saline");



sgtitle([monkey + date]);


disp('converting finished')