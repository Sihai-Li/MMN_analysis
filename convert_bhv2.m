clear all; close all; 

output_dict = "D:\Uchi_data\Sly_beh\MMN_data\converted_data\"
[Neurons_num Neurons_txt] = xlsread('Sly_MNM_list.xlsx','list');

for n = 1:length(Neurons_txt)
       beh = mlread("D:\Uchi_data\Sly_beh\MMN_data\" + Neurons_txt{n})
       save((output_dict + Neurons_txt{n}(1:(length(Neurons_txt{n})-5)) + '.mat'), 'beh')
end

disp('converting finished')