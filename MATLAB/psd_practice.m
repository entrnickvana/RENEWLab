
%% https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html

clear all;
close all;

%%% Continious time approximation
%fc = 1e6;
%tc = [0:1024-1]/fc;
%N = length(tc);
%frq = 0:fc/N:fc-(1/fc);
%x_rect_len = (1/16)*N;
%x_rect = zeros(1, N);
%x_rect(1:x_rect_len) = ones(1, x_rect_len);
%
%figure(); subplot(311);
%plot(x_rect);
%subplot(312);
%X_RECT_F = (1/N)*abs(fft(x_rect, 1024));
%plot(frq, X_RECT_F);
%subplot(313);
%plot(frq-(fc/2),fftshift(X_RECT_F));

fs = 5e6;
Ts = 1/fs;
smp_per_sym = 64;
t = [0:(30*64)-1]*Ts;  % 30 Symbol intervals of 64 samples each
QAM_ORDER = 16;
N_SYMS = 30;
CYC_PER_SAMP = 1/64;
SAMP_PER_CYC = 64;
%M = sqrt(QAM_ORDER);
M = QAM_ORDER;
%tx_data = (randi(M, 1, N_SYMS) - (M+1)/2) + i*(randi(M, 1, N_SYMS) - (M+1)/2);
tx_data = (randi(M, 1, N_SYMS) - (M+1)/2);
tx_data = (2/(M-1))*tx_data;
tx_sym_wdws = repelem(tx_data, SAMP_PER_CYC);
SUB_IDX = circshift([1 zeros(1,SAMP_PER_CYC-1)], 1);
SUB_IDX(16) = 1;
tx_sub_carr = ifft([SUB_IDX], 64);
if(1) figure; stem(real(tx_sub_carr)); hold on; stem(imag(tx_sub_carr)); title('Sub Carrier Block'); end;
tx_carr = repmat(real(tx_sub_carr),1, 30);
tx_carr = tx_carr + i*repmat(imag(tx_sub_carr),1, 30);
tx_vec = tx_carr.*tx_sym_wdws;

if(0) figure; stem(real(tx_data)); hold on; stem(imag(tx_data)); end;
if(1) figure; subplot(211); stem(real(tx_sym_wdws)); hold on; subplot(212); stem(imag(tx_sym_wdws)); end;
if(1) figure; plot(real(tx_carr)); hold on; plot(imag(tx_carr)); end;
if(1) figure; plot(real(tx_vec)); hold on; plot(imag(tx_vec)); end;
if(1) figure; stem(real(tx_vec)); hold on; stem(imag(tx_vec)); end;


    
return;

wc = pi/4;
fc = wc * (1/(2*pi));


N = 1024;
n = 0:N-1;
%x_cos = cos(2*pi*(1/8)*n) + randn(size(n));
x_cos = cos(2*pi*(1/8)*n);
x_sinc = (1/((pi/4)*(1/pi)))*sinc(pi*(1/8)*(n-N/2));
%X_F = fft(x_cos + x_sinc);
X_F = fft(x_sinc, 1024);
X_F_one = (1/N)*abs(X_F(1:N/2+1));
X_PSD = (1/(2*pi*N)) * abs(X_F).^2;
X_F = (1/N)*abs(fft(x_sinc));
X_PSD_one = X_PSD(1:N/2+1);
X_PSD_one(2:end-1) = 2*X_PSD_one(2:end-1);
nfreq = [0:2*pi/N:2*pi-(2*pi/N)] - pi;
%nfreq = [0:2*pi/N:2*pi-(2*pi/N)] - pi;
nfreq_one = 0:2*pi/N:pi;
figure; grid on;
subplot(311)
plot(nfreq/pi, fftshift(X_F));
title("Periodogram using FFT");
xlabel("Normalized Frequency (\times\pi rad\sample)");
ylabel("Power/Frequency (dB/(rad/Sample)))");

subplot(312)
plot(nfreq/pi, pow2db(fftshift(X_PSD)));
title("Periodogram using FFT");
xlabel("Normalized Frequency (\times\pi rad\sample)");
ylabel("Power/Frequency (dB/(rad/Sample)))");

subplot(313)
plot(nfreq_one/pi, pow2db(X_PSD_one));
title("Periodogram using FFT");
xlabel("Normalized Frequency (\times\pi rad\sample)");
ylabel("Power/Frequency (dB/(rad/Sample)))");







return;

fs = 1000;
Tsamp = 1/fs; % 1ms
f1 = 100;
t = 0:Tsamp:1-Tsamp;

v = (1/10)*randn(size(t)); % Real valued and even length
x100 = cos(2*pi*f1*t);

order = 4;
s = randi(order, 1, 125) - ((order + 1)/2);
s = 100*repelem(s, 8);

x_sym = x100.*s;
x_sym_noise = x_sym + v;
x = x_sym_noise;

N = length(x);

% Fourier Transform
xdft = fft(x);

% Only take positive frequencies
xdft = xdft(1:N/2+1);

% Scale by Tsamp/length(X) with Power of Signal
psdx = (1/(fs*N)) * abs(xdft).^2;

% Convert to analytic signal by scaling by 2, remembering that dc appears in first and last indices
psdx(2:end-1) = 2*psdx(2:end-1);

% divide nyquist zone (fs/2) into intervals of fs/N
freq = 0:fs/length(x):fs/2; 

psdx_smooth = conv((1/4)*ones(1, 4), psdx);
psdx_smooth = psdx_smooth(1:end-4+1);

figure;
subplot(2,1,1)
plot(freq, pow2db(psdx));
grid on;
title("Periodogram Using FFT");
xlabel("Frequency (Hz)");
ylabel("Power/Frequency (dB/Hz)");

subplot(2,1,2)
plot(freq, pow2db(psdx_smooth));
grid on;
title("Periodogram Using FFT");
xlabel("Frequency (Hz)");
ylabel("Power/Frequency (dB/Hz)");
