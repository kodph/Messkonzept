% This programm is used to plot the time-pressure graphic. It reads all
% data in folder "C:\Messkonzept\Drucksensordata", output images and store
% them in folder "C:\Messkonzept\Graphic\time_pressure\graphic_"


clc;clear;

% Double precision calculation (15 decimal places)
format long g;
first_foot_total=[];
time_total=[];

for count=1:100
    if not(isfile(strcat('C:\Messkonzept\Drucksensordata\Drucksensor_',num2str(count),'.txt')))
        break
    end
    
% read pressure sensor data
index_total=[];
File_Druck=load(strcat('C:\Messkonzept\Drucksensordata\Drucksensor_',num2str(count),'.txt'));
Time_hour_Druck=File_Druck(:,1);
Time_mins_Druck=File_Druck(:,2);
Time_sec_Druck=File_Druck(:,3);
Leftfoot_Druck=File_Druck(:,4);
Rightfoot_Druck=File_Druck(:,5);

% time converstion
Time_in_second_Druck=Time_hour_Druck.*3600+Time_mins_Druck.*60+Time_sec_Druck;
All_Druck=[Time_in_second_Druck,Leftfoot_Druck,Rightfoot_Druck];
sum=Rightfoot_Druck+Leftfoot_Druck;

Time_Druck=All_Druck(:,1); 
Weight_Druck_left=All_Druck(:,2); %80Hz
Weight_Druck_right=All_Druck(:,3); %80Hz

% Plot of pressure data
figure;
plot(Time_in_second_Druck,Rightfoot_Druck,'r')
xlabel('Second');ylabel('Weight(g)');
title(strcat('foot weight',num2str(count)));
hold on;
plot(Time_in_second_Druck,Leftfoot_Druck,'b')
plot(Time_in_second_Druck,sum)
legend('Rightfoot weight','Leftfoot weight','Sum weight');

% save plots
print(gcf,strcat("C:\Messkonzept\Graphic\time_pressure\graphic_",num2str(count)),'-dpng','-r600');
end