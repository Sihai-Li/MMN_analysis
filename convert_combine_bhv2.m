clear all; close all; 

monkey = "Stan";
date = "2022_0610";
phase = "control";
in_dict = append( "D:\Uchi_data\Stan_Nev\",monkey,"\",date, "\",phase, "\");
output_dict =append( "D:\Uchi_data\Stan_Nev\",monkey,"\",date, "\");
[Neurons_num Neurons_txt] = xlsread('D:\Uchi_data\Stan_Nev\inactivation_project.xlsx','Sheet1');

for n = 1:length(Neurons_txt)
       beh= mlread(append(in_dict, Neurons_txt{n}));
       save((output_dict + Neurons_txt{n}(1:(length(Neurons_txt{n})-5)) + '_' + phase + '.mat'), 'beh');
end

disp('converting finished')