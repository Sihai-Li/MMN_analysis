Aclear all; close all; 

output_dict = "/Users/sihaili/Documents/Data/Sly_beh/convert_data/"
[Neurons_num Neurons_txt] = xlsread('/Users/sihaili/Documents/Data/Sly_beh/Sly_beh_list.xlsx','Sheet1');

for n = 1:length(Neurons_txt)
       beh = mlread("/Users/sihaili/Documents/Data/Sly_beh/" + Neurons_txt{n})
       save((output_dict + Neurons_txt{n}(1:(length(Neurons_txt{n})-5)) + '.mat'), 'beh')
end

disp('converting finished')