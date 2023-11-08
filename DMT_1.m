% Load the ECG data
[filename,pathname]=uigetfile('*.*','Select ECG Signal');
filewithpath=strcat(pathname,filename);
ecg=load(filename);
% Define the sampling frequency
Fs = 360; % Hz

% Define the start and end indices for the 10-second segment
start_index = 1; % Start at the beginning of the signal
end_index = start_index +10 *Fs - 1; % Extract 10 seconds of data

% Extract the 10-second segment from =loadthe ECG signal
ecg_data = ecg.val(1, start_index:end_index);
% Define the passband frequencies (in Hz)
low_freq = 0.5; % Lower cutoff frequency
high_freq =50; % Upper cutoff frequency

% Design the bandpass filter using 'butter' filter design
order = 4; % Filter order
[b, a] = butter(order, [low_freq high_freq] / (Fs/2), 'bandpass');

% Apply the bandpass filter to the ECG segment
ecg_filtered= filtfilt(b, a, ecg_data);


ecgsig=(ecg_filtered)./200;
t=1:length(ecgsig);
tx=t./Fs;

wt=modwt(ecgsig,4,'sym4');
wtrec=zeros(size(wt));
wtrec(3:4,:)=wt(3:4,:);

y=imodwt(wtrec,'sym4');
y=abs(y).^2;
avg=mean(y);

[Rpeaks,locs] = findpeaks(y,t, 'MinPeakHeight',8*avg, 'MinPeakDistance', 50);
RR_intervals = diff(locs) / Fs
heart_rate = 60 / mean(RR_intervals);

subplot(2,1,1)
plot(tx,ecgsig);

subplot(2,1,2)
plot(tx,y);
hold on;
plot(tx(locs), Rpeaks , 'ro', 'MarkerSize', 10);
title(strcat('R peaks found and Heart Rate: ',num2str(heart_rate)))

disp(strcat('Heart Rate =',num2str(heart_rate)))
if heart_rate>60 && heart_rate<100
disp(strcat('Normal Heart Rate. Patient is healthy'))
elseif heart_rate < 60
    disp(strcat('Slow heart rate. Patient has Bradycardia.'))
elseif heart_rate>100
    disp(strcat('Fast heart rate. Patient has Tachycardia'))
end




