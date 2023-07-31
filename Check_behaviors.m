clear all; close all;
name = "20230731";
load('/Users/sihaili/Documents/Data/Sly_beh/convert_data/20230731_Sly_MMN_steps.mat');

num_cond = 36
overall_cond = zeros(1, num_cond)
correct_cond = zeros(1, num_cond)
RT_cond = nan(num_cond, 200)
overall = 0

for n = 1:length(beh)

    for i = 1: num_cond
        if beh(n).Condition == i && (beh(n).TrialError == 0 || beh(n).TrialError == 8 )
            overall_cond(i) = overall_cond(i) + 1

            if beh(n).TrialError == 0 
                correct_cond(i) = correct_cond(i) + 1
                RT_cond(i, correct_cond(i)) =  beh(n).ReactionTime
            end
        end

    end
end

for i = 1: num_cond
    mean_RT(i) = nanmean(RT_cond(i,:))
end

cond_performance = correct_cond./overall_cond;
bar(cond_performance)

h = figure(1)

subplot(1,2,1)
p1=bar(cond_performance);
ylim([0 1]);
title(['Performance' + name])

subplot(1,2,2)
p2=bar(mean_RT(1:num_cond));
title('RT')

saveas(h, ['/Users/sihaili/Documents/Data/Sly_beh/convert_data/' + name+ 'test.jpg'])
disp('finished')




