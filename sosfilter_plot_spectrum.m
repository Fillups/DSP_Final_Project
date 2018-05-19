function [fill] = sosfilter_plot_spectrum( sos,x,Fs,name,noise )
%filters data and plots the filtered spectrum, takes transfer function
%coefficients, b & a, data x, and sampling frequency Fs
%returns the filtered data to the user

%This program plots the filtered spectrum

%filter the data
fill = sosfilt(sos,x);

%create the spectra
spec = create_spectrum(Fs,fill);

%plot
figure();
subplot(2,1,1);
plot(spec(:,1),abs(spec(:,2)));
title([name,', Magnitude, ',noise,'-Noise'])
xlabel('f'),ylabel('|Y(\omega)|');
xlim([-Fs/2 Fs/2]);
subplot(2,1,2);
plot(spec(:,1),unwrap(angle(spec(:,2))));
title([name,', Phase, ',noise,'-Noise']);
xlabel('f'),ylabel('\angleY(\omega) (radians)') 
xlim([-Fs/2 Fs/2]);

end