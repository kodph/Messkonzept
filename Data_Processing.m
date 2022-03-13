% This program is used to calculate the gap acceptance. The first step is
% to find the time point in which the pedestrain intends to cross the
% street. Then it will find the nearst time point in Lidardata. The
% distance at this time point can be considered as the gap acceptance.It
% reads the data in folder "C:\Messkonzept\Drucksensordata" and folder 
% "C:\Messkonzept\Lidarsensordata\Lidar_matlab". It outputs the
% time-pressure plots and time-distance plots. The time points in which the
% pedestrain intends to cross the street are marked in plots. The result is
% stored as a xls data,"C:\Messkonzept\End_Data.xlsx". The plots are stored
% in folder "C:\Messkonzept\Graphic\End_Data".


clc;clear;

% Double precision calculation (15 decimal places)
format long g;

first_foot_total=[];
time_total=[];
index_total=[];
Match_Sequencenumber=[];
Match_Strength=[];
Match_Distance_Lidar=[];
filename="C:\Messkonzept\End_Data.xlsx";

% read data from Drucksensor_1 to Drucksensor_100
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
sum=Rightfoot_Druck+Leftfoot_Druck;

% read lidarsensor data
File_Lidar=load(strcat('C:\Messkonzept\Lidarsensordata\Lidar_matlab\Lidarsensor_',num2str(count),'.txt'));
Distance_Lidar=File_Lidar(:,1);
Strength_Lidar=File_Lidar(:,2);
Time_hour_Lidar=File_Lidar(:,4);
Time_mins_Lidar=File_Lidar(:,5);
Time_sec_Lidar=File_Lidar(:,6);

% Time Conversion
Time_in_second_Druck=Time_hour_Druck.*3600+Time_mins_Druck.*60+Time_sec_Druck;
All_Druck=[Time_in_second_Druck,Leftfoot_Druck,Rightfoot_Druck];

Time_in_second_Lidar=Time_hour_Lidar.*3600+Time_mins_Lidar.*60+Time_sec_Lidar;
All_Lidar=[Time_in_second_Lidar,Distance_Lidar,Strength_Lidar];

% Rename 
Time_Druck=All_Druck(:,1); 
Time_Lidar=All_Lidar(:,1);
Weight_Druck_left=All_Druck(:,2); %80Hz
Weight_Druck_right=All_Druck(:,3); %80Hz
Distance_Lidar=All_Lidar(:,2); %100Hz
Strength_Lidar=All_Lidar(:,3);

% Find the time when the left foot and the right foot leave the board
time_all=[];
time_right=[];
time_left=[];
for i=3:length(Time_Druck)
    % From beginning to end, find the time when all feet leave the board.
    % In this time sum should be zero.To elimate the noise we set here 350
    if sum(i-2)>350&&sum(i-1)<350&&sum(i)<sum(i-1)
        for k = i:-1:3
        % From the time point in which the two feet leave the board, to
        % beginning, find the first time point in which right foot leaves
        % the board. In this time Weight_Druck_right should be zero.To
        % elimate the noise we set here 1000.
            if Weight_Druck_right(k-2)>1000&&Weight_Druck_right(k-1)<1000&&Weight_Druck_right(k)<Weight_Druck_right(k-1)
            time_right=[time_right,k];
            break
            end
        end
        for k = i:-1:3
        % From the time point, in which the two feet leave the board, to
        % beginning, find the first time point in which left foot leaves
        % the board. In this time Weight_Druck_left should be zero.To
        % elimate the noise we set here 1000.
            if Weight_Druck_left(k-2)>1000&&Weight_Druck_left(k-1)<1000&&Weight_Druck_left(k)<Weight_Druck_left(k-1)
            time_left=[time_left,k];
            break
            end
        end
    end
end
        
% Determine which foot move forward first
first_foot=[];
for j=1:length(time_right)
    if time_right(j)-time_left(j)>0
       first_foot=[first_foot,1,time_left(j)];
    else 
       first_foot=[first_foot,2,time_right(j)];
    end 
end

% Find the time at which the slope alternates between positive and negative
% along the pressure curve. We test only the foot which moves first.
time=[];
for k=1:2:length(first_foot)
     % Left foot moves first
     if first_foot(k)==1
        point=first_foot(k+1)-2;
        % Find a point before which the slope is positive and after which the slope is negative.Then break 
        for m=point:-1:3
            if (Weight_Druck_left(m-2)-Weight_Druck_left(m-1))<0&&(Weight_Druck_left(m+1)-Weight_Druck_left(m+2))>0
            break
            end
        end
        time=[time,Time_Druck(m)];
     end  
     
     % Right foot moves first
     if first_foot(k)==2
        point=first_foot(k+1)-2;
        % Find a point before which the slope is positive and after which the slope is negative.Then break
        for n=point:-1:3
            if (Weight_Druck_right(n-2)-Weight_Druck_right(n-1))<0&&(Weight_Druck_right(n+1)-Weight_Druck_right(n+2))>0
            break
            end    
        end
        time=[time,Time_Druck(n)];
     end
end

% Find the nearst timestamp in Lidarsensor data and read the diastance
for p=1:length(time)
    time_difference=abs(Time_Lidar'-time(p));
    [min_time_difference,index]=min(time_difference);
    % The timestamp will not be exactly same because the frequency are
    % different.We find a point that is the most similar,i.e.the point with
    % the smallest absolute value.
    Match_position=index;
    Match_Sequencenumber=[Match_Sequencenumber,length(Match_Sequencenumber)+1];
    Match_Strength=[Match_Strength,Strength_Lidar(index)];
    Match_Distance_Lidar=[Match_Distance_Lidar,Distance_Lidar(index)];
    index_total = [index_total,index];
end

% Plot of pressure sensor
figure;
plot(Time_in_second_Druck,Rightfoot_Druck,'r')
xlabel('Second');ylabel('Weight(g)');
title(strcat('foot weight',num2str(count)));
hold on;
plot(Time_in_second_Druck,Leftfoot_Druck,'b')
plot(Time_in_second_Druck,sum)
for b=1:1:length(time)
    [e,f] = find(Time_in_second_Druck==time(b));
    plot(time(b),Weight_Druck_left(e),'rs',time(b),Weight_Druck_right(e),'rs');
end
legend('Rightfoot weight','Leftfoot weight','Sum weight');

% save plots
print(gcf,strcat("C:\Messkonzept\Graphic\End_Data\pressure\pressure_",num2str(count)),'-dpng','-r600');

% Plot of Lidarsensor
figure;
plot(Time_in_second_Lidar,Distance_Lidar);
hold on;
for b=1:1:length(time)
    [e,f] = find(Time_in_second_Lidar==time(b));
    plot(time(b),Distance_Lidar(index_total(b)),'rs');
end
xlabel('Second');ylabel('Distance(cm)');
legend('Distance from Lidar');
title(strcat('Lidar',num2str(count)));

% save plots
print(gcf,strcat("C:\Messkonzept\Graphic\End_Data\lidar\lidar_",num2str(count)),'-dpng','-r600');

% Counting the left and right foot and the moment of taking a step
first_foot_total = [first_foot_total,first_foot];
time_total = [time_total,time];
end

first_foot_total_1 = first_foot_total(1:2:length(first_foot_total));
End_Data = [Match_Sequencenumber',Match_Strength',Match_Distance_Lidar',first_foot_total_1',time_total'];

% add title
End_Data = ["Match_Sequencenumber","Match_Strength","Match_Distance_Lidar","Left/Right","Time";End_Data];
writematrix(End_Data,filename)