function [ Freqinfo ] = create_spectrum( fs,y )

%take sampling frequency fs and turn it into frequency in radians for scaling

%set 16 bit resolution
n = 2^16;

%compute fft with 16-bit resolution and center
Y = fftshift(fft(y,n));

%scale and center frequency bins around w=0
f = ((-n/2:n/2-1)*(fs/n)).';

%organize the computed information into a matrix
%1st column is frequency, 2nd column is frequency domain transformed values
Freqinfo = [f,Y];

end