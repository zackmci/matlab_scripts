%% Measuring Signal Similarities 
% This example shows how to measure signal similarities. It will help you
% answer questions such as: How do I compare signals with different lengths
% or different sampling rates? How do I find if there is a signal or just
% noise in a measurement? Are two signals related? How to measure a delay
% between two signals (and how do I align them)? How do I compare the
% frequency content of two signals? Similarities can also be found in
% different sections of a signal to determine if a signal is periodic.

%   Copyright 2012-2014 The MathWorks, Inc.

%% Comparing Signals with Different Sampling Rates
% Consider a database of audio signals and a pattern matching application
% where you need to identify a song as it is playing. Data is commonly
% stored at a low sampling rate to occupy less memory.

% November 2-19, 2016


clear all; close all;

% ** Make sure to change below if looking at a mixing region problem **
filename='granular_flow_fric_7900_fc';
%filename='box512_ht_1_fc';
%filename='box512_ht_fc';
%finaltime=1120;
finaltime=9999;
%finaltime=50;
time_factor=0.01;
angle_bins=20;      % Number of bins for the circle
bin_angles=(2*pi)/angle_bins;
cut_time=1807;

cd('/home/zack/Documents/csv_data_files/')

% Load data
cd('/home/zack/Documents/csv_data_files/results/')
list1=csvread(['As_and_thetas_',filename,'_',num2str(angle_bins), ...
    'bins.csv'],0,0);
list2=csvread(['Orientations_',filename,'_',num2str(angle_bins), ... 
    'bins.csv'],0,0);
%cd('/home/jmschl/Desktop/MixingCalculations/csvData/')

contact_a=list1(:,1);
contact_theta=list1(:,2);
fn_a=list1(:,3);
fn_theta=list1(:,4);
ft_a=list1(:,5);
ft_theta=list1(:,6);
binning_contacts=list2(:,1:finaltime);
binning_forces_n=list2(:,finaltime+1:2*finaltime);

cd('/home/zack/Documents/csv_data_files/')

a=csvread(['ave_coord_',filename,'.csv'],0,0);
%a=a(:,2);   % Pull out only mixing region coordination numbers

T1=a;
T2=contact_a;

T1(1:cut_time)=[];
T2(1:cut_time)=[];

T1=detrend(T1);
%T1=T1-T1_trend;
T2=detrend(T2);
%T2=T2-T2_trend;


%T1=T1-(mean(T1)-mean(T2));

Fs1=100; Fs2=100; Fs=100;

figure
ax(1) = subplot(211); 
plot((0:numel(T1)-1)/Fs1,T1,'k');
ylabel('Coordination');
ax(2) = subplot(212); 
plot((0:numel(T2)-1)/Fs2,T2,'r'); 
ylabel('Contact Anisotropy');
xlabel('Time (secs)'); 
linkaxes(ax(1:2),'x')


%% Finding a Signal in a Measurement
% We can now cross-correlate signal S to templates T1 and T2 with the
% |xcorr| function to determine if there is a match.
% 
% [C1,lag1] = xcorr(T1,T2);        
% Fs=8;
% figure
% plot(lag1/Fs,C1,'k');
% ylabel('Amplitude');
% grid on
% title('Cross-correlation between Contact anisotropy and Coordination number')
% xlabel('Time(secs)'); 
% axis([-50 50 0 15])


%% Comparing the Frequency Content of Signals
% A power spectrum displays the power present in each frequency. Spectral
% coherence identifies frequency-domain correlation between signals.
% Coherence values tending towards 0 indicate that the corresponding
% frequency components are uncorrelated while values tending towards 1
% indicate that the corresponding frequency components are correlated.
% Consider two signals and their respective power spectra.

Fs = 100;         % Sampling Rate

[P1,f1] = periodogram(T1,[],[],Fs,'power');
%[P1,f1]=periodogram(T1,'power');
[P2,f2] = periodogram(T2,[],[],Fs,'power');
%[P2,f2]=periodogram(T2,'power');

% [P1,f1]=periodogram(T1,hamming(length(T1)),length(T1),Fs,'power');
% [P2,f2]=periodogram(T2,hamming(length(T2)),length(T2),Fs,'power');

figure
t = (0:numel(T1)-1)/Fs;
subplot(221);
plot(t,T1,'k');
ylabel('Coordination');
grid on
title('Time Series')
%xlim([0 .44])
%ylim([-0.15 0.15])
subplot(223);
plot(t,T2);
ylabel('Contact Anisotropy');
grid on
xlabel('Time (secs)')
%xlim([0 .44])
%ylim([-0.15 0.15])
subplot(222); 
%plot(1./f1,P1,'k');
plot(f1,P1,'k');
ylabel('Coordination Number');
grid on;
%axis tight
xlim([0 0.75])
title('Power Spectrum')
subplot(224);
%plot(1./f2,P2);
plot(f2,P2);
ylabel('Contact Anisotropy');
grid on; 
%axis tight
xlim([0 0.75])
xlabel('Frequency (Hz)')

%%
% The |mscohere| function calculates the spectral coherence between the two
% signals. It confirms that sig1 and sig2 have two correlated components
% around 35 Hz and 165 Hz. In frequencies where spectral coherence is high,
% the relative phase between the correlated components can be estimated
% with the cross-spectrum phase.

[Cxy,f] = mscohere(T1,T2,[],[],[],Fs);
Pxy     = cpsd(T1,T2,[],[],[],Fs);
phase   = -angle(Pxy)/pi*180;
[pks,locs] = findpeaks(Cxy,'MinPeakHeight',0.75);

figure
%subplot(211);
plot(f,Cxy);
title('Coherence Estimate');
%grid on;
%hgca = gca;
%hgca.XTick = f(locs);
%hgca.YTick = .75;
%axis([0 4 0 1])
%subplot(212);
%plot(f,phase); 
%title('Cross-spectrum Phase (deg)');
%grid on;
%hgca = gca;
%hgca.XTick = f(locs); 
%hgca.YTick = round(phase(locs));
%xlabel('Frequency (Hz)'); 
%axis([0 4 -360 360])

%%
% The phase lag between the 35 Hz components is close to -90 degrees, and
% the phase lag between the 165 Hz components is close to -60 degrees.

%% Finding Periodicities in a Signal
% Consider a set of temperature measurements in an office building during
% the winter season. Measurements were taken every 30 minutes for about
% 16.5 weeks.

load officetemp.mat  % Load Temperature Data
Fs = 1/(60*30);                 % Sample rate is 1 sample every 30 minutes
days = (0:length(temp)-1)/(Fs*60*60*24); 

figure
plot(days,temp)
title('Temperature Data')
xlabel('Time (days)'); 
ylabel('Temperature (Fahrenheit)')
grid on

%% 
% With the temperatures in the low 70s, you need to remove the mean to
% analyze small fluctuations in the signal. The |xcov| function removes the
% mean of the signal before computing the cross-correlation. It returns the
% cross-covariance. Limit the maximum lag to 50% of the signal to get a
% good estimate of the cross-covariance.

maxlags = numel(temp)*0.5;
[xc,lag] = xcov(temp,maxlags);         

[~,df] = findpeaks(xc,'MinPeakDistance',5*2*24);
[~,mf] = findpeaks(xc);

figure
plot(lag/(2*24),xc,'k',...
     lag(df)/(2*24),xc(df),'kv','MarkerFaceColor','r')
grid on
xlim([-15 15]);
xlabel('Time (days)')
title('Auto-covariance')

%%
% Observe dominant and minor fluctuations in the auto-covariance. Dominant
% and minor peaks appear equidistant. To verify if they are, compute and
% plot the difference between the locations of subsequent peaks.

cycle1 = diff(df)/(2*24);
cycle2 = diff(mf)/(2*24);

subplot(211);
plot(cycle1); 
ylabel('Days'); 
grid on
title('Dominant peak distance')
subplot(212); 
plot(cycle2,'r');
ylabel('Days');
grid on
title('Minor peak distance')

mean(cycle1)
mean(cycle2)

%%
% The minor peaks indicate 7 cycles/week and the dominant peaks indicate 1
% cycle per week. This makes sense given that the data comes from a
% temperature-controlled building on a 7 day calendar. The first 7-day
% cycle indicates that there is a weekly cyclic behavior of the building
% temperature where temperatures lower during the weekends and go back to
% normal during the week days. The 1-day cycle behavior indicates that
% there is also a daily cyclic behavior - temperatures lower during the
% night and increase during the day.

displayEndOfDemoMessage(mfilename)