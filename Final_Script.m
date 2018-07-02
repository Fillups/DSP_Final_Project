%main program
%Kevin Phillips

clear all, close all, clc

%%
%load the corrupted data

load('ProjectMLKnew.mat');
x = MLK_HighNoise;
y = MLK_LowNoise;

%%
%analyze the audio

spechighnoise = create_spectrum(Fs,x);
speclownoise = create_spectrum(Fs,y);

%plot High
figure();
subplot(2,1,1);
plot(spechighnoise(:,1),abs(spechighnoise(:,2)));
title('Magnitude sampled at 44.1 kHz, 16-bit resolution');
xlabel('f'),ylabel('|Y(\omega)|');
xlim([-Fs/2 Fs/2]);
subplot(2,1,2);
plot(spechighnoise(:,1),unwrap(angle(spechighnoise(:,2))));
title('Phase sampled at 44.1 kHz, 16-bit resolution');
xlabel('f'),ylabel('\angleY(\omega) (radians)') 
xlim([-Fs/2 Fs/2]);

%plot Low
figure();
subplot(2,1,1);
plot(speclownoise(:,1),abs(speclownoise(:,2)));
title('Magnitude sampled at 44.1 kHz, 16-bit resolution');
xlabel('f'),ylabel('|Y(\omega)|');
xlim([-Fs/2 Fs/2]);
subplot(2,1,2);
plot(speclownoise(:,1),unwrap(angle(speclownoise(:,2))));
title('Phase sampled at 44.1 kHz, 16-bit resolution');
xlabel('f'),ylabel('\angleY(\omega) (radians)') 
xlim([-Fs/2 Fs/2]);

%%
%create butterworth IIR SOS filter and filter the corrupted sound file

%BUTTERWORTH IIR
name = 'Butterworth';
%find the order of the butterwoth filter
%specify parameters
%cutoff freq of 2750 Hz normalized
Wp = 2750/(Fs/2);
%stopband 3000 Hz normalized
Ws = 3000/(Fs/2);
%passband ripple dB
Rp = .1;
%stopband attentuation dB
Rs = 100;

%find the butter order in normalized frequency and the cutoff
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
%calculate butterworth zeros, poles, and gain k
[z,p,k] = butter(n,Wn);
%calculate the second order section respesentation of the filter
sos = zp2sos(z,p,k);

%view the filter characteristics
fvtool(sos)

%%
%create Kaiser FIR impulse window and filter the corrupted sound file

%KAISER
%ex 7.6.1
name = 'Kaiser';
%ripple of 1/100e3 same as parks mclellan and butterworth design
%ripple is same for pass and stopband for Kaiser window
delta = 1/100e3;
%normalized edge of passband
wp = 2750*pi/(Fs/2);
%normalized beginnihdng of stopband
ws = 3000*pi/(Fs/2);
%find symmetric cutoff, average of normalized frequencies
wc = (wp+ws)/2;
%find the width of the transition band
deltaw = ws-wp;
%find linear gain A
A = -20*log10(delta);
%find beta B 
if A > 50
    beta = .1102*(A-8.7);
elseif A >= 21 && A <=50
    beta = .5842*(A-21)^0.4+.07886*(A-21);
elseif A < 21
    beta = 0;
end
%find length parameter M, find length len, find alpha 
M = ceil((A-8)/(2.285*deltaw));
len = M+1;

%create kaiser window and apply it to the desired impulse response to form
%the filter
%create x axis, of samples
n=(0:M).';
%create kaiser coefficients wn
wn = kaiser(len,beta);
%create ideal impulse response
hdn = wc/pi*sinc((n-M/2)*wc/pi);
%multiply the desired impulse response by the filter coefficients
hd = hdn.*wn;

%view the filter characteristics
fvtool(hd)

%%
%create Parks-McClellan equiripple FIR filter and filter the corrupted sound

%PARKS
name = 'Parks-McClellan';
%Passband ripple
rp = .1;
%Stopband ripple
rs = 100;
%Cutoff frequencies, [pass stop]
f = [2750 3000].';
%Desired amplitudes [pass stop]
a = [1 0].';
%change ripples from db to gain
dev = [(10^(rp/20)-1)/(10^(rp/20)+1)  10^(-rs/20)].';

%input frequency vector, amplitude vector, deviation, and sampling
%frequency
%output order, normalized frequency band edges, frequency band amplitudes,
%and weights
[n,fo,ao,w] = firpmord(f,a,dev,Fs);
%input order, normalized frequency band edges, frequency band amplitudes,
%and weights
%output transfer function numerator b (denominator is 1 for FIR's)
b = firpm(n,fo,ao,w);

%view the filter characteristics
fvtool(b)

%%
%Plot the filtered spectra of the sound file

%PLOT

%filter the data
filbutthighnoise = sosfilt(sos,x);
filbuttlownoise = sosfilt(sos,y);
%filter the data
filkaiserhighnoise = filter(hd,1,x);
filkaiserlownoise = filter(hd,1,y);
%filter the data
filparkshighnoise = filter(b,1,x);
filparkslownoise = filter(b,1,y);

%create the spectra
spechighnoisebutt = create_spectrum(Fs,filkaiserhighnoise);
speclownoisebutt = create_spectrum(Fs,filkaiserlownoise);
%create the spectra
spechighnoisekais = create_spectrum(Fs,filkaiserhighnoise);
speclownoisekais = create_spectrum(Fs,filkaiserlownoise);
%create the spectra
spechighnoiseparks = create_spectrum(Fs,filkaiserhighnoise);
speclownoiseparks = create_spectrum(Fs,filkaiserlownoise);


%plot High
figure();
subplot(2,1,1);
hold on;
plot(spechighnoisebutt(:,1),abs(spechighnoisebutt(:,2)),'r');
plot(spechighnoisekais(:,1),abs(spechighnoisekais(:,2)),'g--');
plot(spechighnoiseparks(:,1),abs(spechighnoiseparks(:,2)),'b:');
title('Magnitude High Noise');
xlabel('f'),ylabel('|Y(\omega)|');
xlim([-5e3 5e3]);
legend('Butterworth','Kaiser','Parks');
hold off;
subplot(2,1,2);
hold on;
plot(spechighnoisebutt(:,1),unwrap(angle(spechighnoisebutt(:,2))),'r');
plot(spechighnoisekais(:,1),unwrap(angle(spechighnoisekais(:,2))),'g--');
plot(spechighnoiseparks(:,1),unwrap(angle(spechighnoiseparks(:,2))),'b:');
title('Phase High Noise');
xlabel('f'),ylabel('\angleY(\omega) (radians)') 
xlim([-5e3 5e3]);
legend('Butterworth','Kaiser','Parks');
hold off;


%plot Low
figure();
subplot(2,1,1);
hold on;
plot(speclownoisebutt(:,1),abs(speclownoisebutt(:,2)),'r');
plot(speclownoisekais(:,1),abs(speclownoisekais(:,2)),'g--');
plot(spechighnoiseparks(:,1),abs(spechighnoiseparks(:,2)),'b:');
title('Magnitude Low Noise');
xlabel('f'),ylabel('|Y(\omega)|');
xlim([-5e3 5e3]);
legend('Butterworth','Kaiser','Parks');
hold off;
subplot(2,1,2);
hold on;
plot(speclownoisebutt(:,1),unwrap(angle(speclownoisebutt(:,2))),'r');
plot(speclownoisekais(:,1),unwrap(angle(speclownoisekais(:,2))),'g--');
plot(speclownoiseparks(:,1),unwrap(angle(speclownoiseparks(:,2))),'b:');
title('Phase Low Noise');
xlabel('f'),ylabel('\angleY(\omega) (radians)') 
xlim([-5e3 5e3]);
legend('Butterworth','Kaiser','Parks');
hold off;

%%
%play the sound

sound(MLK_HighNoise,Fs)
pause(12)
clear sound
sound(filkaiserhighnoise,Fs)
pause(12)
clear sound