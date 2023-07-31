%%edited by Sihai Li, 12/08/2022 for MGS task in Dave Freedman's lab
%%used for plotting saccadic endpoints for a single MGS session and RT for
%%each location

clear all; close all;
clc;
color_pallet = {[255 105 97], [255 180 128], [248 243 141], [66 214 164], [8 202 209], [89 173 246], [157 148 255], [199 128 232]};
% filename = 'D:\Uchi_data\Stan_Nev\Stan\2022_0610\control\20220610_stanton_mem_saccade_pseudo.bhv2'
% filename = 'D:\Uchi_data\Stan_Nev\Stan\2022_0610\inact\20220610_stanton_mem_saccade_pseudo(1)_combined.bhv2'
filename = 'D:\Uchi_data\Stan_Nev\Stan\2022_0610\inact\20220610_stanton_mem_saccade_pseudo(1)_combined.mat'
% beh = mlread(filename)
load(filename);


ntr = [];
x_endall = [];
y_endall = [];
for i = 1:length(beh)
    if beh(i).TrialError == 0
        ntr = [ntr i]
    end
end


for j = 1:length(ntr)
    ntrt = ntr(j)
    fix_off =  find(beh(ntrt).BehavioralCodes.CodeNumbers == 36); %code 36, fixation offset
    reward_on =  find(beh(ntrt).BehavioralCodes.CodeNumbers == 96); %code 96, reward given
    test_time = round((round(beh(ntrt).BehavioralCodes.CodeTimes(fix_off)/1000,3)*1000)): round((round(beh(ntrt).BehavioralCodes.CodeTimes(reward_on)/1000,3)*1000)); % need to check how long is the response window
    %     test_time = round((round(beh(ntrt).BehavioralCodes.CodeTimes(fix_off)/1000,3)*1000)): round((round(beh(ntrt).BehavioralCodes.CodeTimes(fix_off)/1000,3)*1000))+400;

    % indexON = find((AllData.trials(ntr).EyeData(:,4)-AllData.trials(ntr).EyeData(1,4))>=1);% auto-calibration check eyedata after fixation period

    if isempty(test_time)
        endpoint = nan;
        newy = nan;
        newx = nan;
    else

        x = beh(ntrt).AnalogData.Eye(test_time,1) %x eyedata
        y = beh(ntrt).AnalogData.Eye(test_time,2) %y eyedata
        newx = []; %reset new x
        newy = []; %reset new y

        numpoints = length(test_time);
        newx(1)=x(1);
        newy(1)=y(1);
        %%%%%%%%%%%%%% 5 points smooth %%%%%%%%%%%%%%%%%
        i = 3;
        n=2;
        while i < numpoints-2
            newx(n) = (x(i-2)+2*x(i-1)+3*x(i)+2*x(i+1)+x(i+2))/9;
            newy(n) = (y(i-2)+2*y(i-1)+3*y(i)+2*y(i+1)+y(i+2))/9;
            i=i+2;
            n=n+1;
        end

        %%% in case some glitch happened(outliner saccade right before
        %%% reward given)

        k = 1;
        saccade_range = 8;
        while k < length(newx)
            if  newx(k) <saccade_range & newx(k) >saccade_range * -1& newy(k) <saccade_range & newy(k) >saccade_range*-1
            elseif  newx(k)>saccade_range |newx(k)<saccade_range * -1| newy(k)>saccade_range |newy(k)<saccade_range * -1
                break
            end
            k = k+1;
        end

        if k<length(newx)
            newx(k:end) = [];
            newy(k:end) = [];
        else
        end

        numpoints = length(newx);
        %calculate dist away from first index of entire selected epoch
        twopoint_dist_from_start = [];
        for z = 2:1:numpoints
            twopoint_dist_from_start(z) = sqrt((newx(z)-newx(1))*(newx(z)-newx(1))+(newy(z)-newy(1))*(newy(z)-newy(1)));
        end

        %to find saccade and endpoint: find most consecutive points where dist increasing away from first index of epoch, which also covers the largest dist

        vel=diff(twopoint_dist_from_start); %find distance between two consecutive points
        start_end_dist_vec=vel>0;
        zero_indices=[0 (find((start_end_dist_vec==0))) numel(start_end_dist_vec)+1];

        dist_away=[];
        for t=1:length(zero_indices)-1 % t is index in zero indices. start would be t+1
            dist_away=[dist_away sum(vel(zero_indices(t)+1:zero_indices(t+1)-1))]; %cumsum the distance between points increasing away from first index of epoch
        end

        st_temp=find(dist_away==max(dist_away));
        endpoint=zero_indices(st_temp+1); %endpoint=zero_indices(st_temp+1)-1; %

        %         %to find startpoint: calculate distance away from endpoint
        %
        %         for z = 1:1:endpoint;
        %             twopoint_dist_to_endpoint(z) = sqrt((newx(z)-newx(endpoint))*(newx(z)-newx(endpoint))+(newy(z)-newy(endpoint))*(newy(z)-newy(endpoint)));
        %         end



        x_endall(j) = newx(endpoint);
        y_endall(j) = newy(endpoint);
        RT(j) = round(endpoint/numpoints*length(test_time))
    end


end

h = figure(1); %a blank figure lol!


% %%plot saccadic endpoint
subplot(1,2,1);
hold on;
for j = 1:length(x_endall)
    a = ntr(j);
    color_number = beh(ntr(j)).Condition;
    c = [color_pallet{color_number}/255]

    %     scatter(x_endall(j),y_endall(j), [color_pallet{color_number}/255],'filled');
    scatter(x_endall(j),y_endall(j),[],c);
end

% %%plot saccadic endpoint
% subplot(1,2,1);
% scatter(x_endall,y_endall,[],[1 1 0]);
% xlim([-10 10]);
% ylim([-10 10]);
% title('Saccadic endpoints')

%%plot distribution of RT
subplot(1,2,2);
histogram(RT,20);
title("Distribution of RT")
line([nanmean(RT) nanmean(RT)],[0 35],'Color','b','LineStyle','--' )


sgtitle(filename); 
