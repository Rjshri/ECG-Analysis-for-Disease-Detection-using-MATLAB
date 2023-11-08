% Load the ECG data
[filename,pathname]=uigetfile('*.*','Select ECG Signal');
filewithpath=strcat(pathname,filename);
ecg=load(filename);

% Define the sampling frequency
Fs = 360; % Hz

% Define the start and end indices for the 10-second segment
start_index = 1; % Start at the beginning of the signal
end_index = start_index +10* Fs - 1; % Extract 10 seconds of data

% Extract the 10-second segment from the ECG signal
ecg_data = ecg.val(1, start_index:end_index);

% Define the passband frequencies (in Hz)
low_freq = 0.5; % Lower cutoff frequency
high_freq =50; % Upper cutoff frequency

% Design the bandpass filter using 'butter' filter design
order = 4; % Filter order
[b, a] = butter(order, [low_freq high_freq] / (Fs/2), 'bandpass');

% Apply the bandpass filter to the ECG segment
ecg_filtered= filtfilt(b, a, ecg_data);



% Step 4: Calculate the first derivative of the filtered signal
derivative_ecg = diff(ecg_filtered );

% Step 5: Square the derivative signal
squared_ecg = derivative_ecg .^ 2;

% Plot the original and filtered ECG segments




% figure;
% plot(squared_ecg);
% title('Filtered ECG Segment (Bandpass)');
% xlabel('Sample Index');
% ylabel('Amplitude');

% Step 6: Integrate the squared signal
% Step 6: Moving-window integration for QRS detection
window_length = round(0.02 * Fs);  % Adjust the window length as needed (e.g., 0.12 seconds)
integrated_ecg = conv(squared_ecg, ones(1, window_length), 'same');
% figure;
% plot(integrated_ecg);


% You can set a threshold and find the peaks in the integrated signal
threshold = 0.5* max(integrated_ecg);  % Adjust the threshold as needed
[peak_values, peak_indices] = findpeaks(integrated_ecg, 'MinPeakHeight', threshold, 'MinPeakDistance', round(0.1 * Fs));
RR_intervals = diff(peak_indices) / Fs
heart_rate = 60 / mean(RR_intervals) ;% Calculate average heart rate in beats per minute
subplot(2,1,1)
plot(ecg_data);
title('Original 10-Second ECG Segment');
xlabel('Sample Index');
ylabel('Amplitude');
subplot(2,1,2)
% Plot the ECG signal with detected R-peaks
t_filtered = (0:length(integrated_ecg) - 1) / Fs;
plot(t_filtered,integrated_ecg);
hold on;
plot(t_filtered(peak_indices), peak_values , 'ro', 'MarkerSize', 10);
title(strcat('R peaks found and Heart Rate: ',num2str(heart_rate)))
xlabel('Time (s)');
ylabel('Amplitude');
legend('Filtered ECG', 'R-Peaks');

disp(strcat('Heart Rate =',num2str(heart_rate)))
if heart_rate>=60 && heart_rate<=100
disp(strcat('Normal Heart Rate. Patient is healthy'))
elseif heart_rate < 60
    disp(strcat('Slow heart rate. Patient has Bradycardia.'))
elseif heart_rate>100
    disp(strcat('Fast heart rate. Patient has Tachycardia'))
end

%