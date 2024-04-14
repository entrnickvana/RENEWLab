

clear all;
close all;

load('ofdm.mat');

% variables from ofdm.mat
fdd_mat;
pilots;
pilots_mat;
preamble;
tx_syms;
tx_syms_mat;
tx_data;
tdd_tx_payload_mat;
tx_payload_vec;

fs = 5e6;
N = length(tx_payload_vec);
t = 1:1/fs:5-(1/fs);
freq = 0:fs/N:fs-(1/fs);
freq_one = freq(1:N/2+1);
freq_one(2:end-1);


%% Smmoth Payload vec to identify bandwidth

% take the one sided fft
%TX_F = (1/N)*fft(tx_payload_vec);

Pxx = (1/(N^2))*abs(fft(tx_payload_vec)).^2;
Pxx_one = Pxx(1:N/2+1);
Pxx_one(2:end-1) = 2*Pxx_one(2:end-1);
figure; plot(freq-(fs/2), fftshift(10*log(Pxx)));

smoothing = 6;
Pxx_smooth_tmp = conv(ones([1 smoothing])./smoothing, Pxx);
Pxx_smooth = Pxx_smooth_tmp(1:end-smoothing+1);
figure; plot(freq-(fs/2), fftshift(10*log(Pxx_smooth)));

% smoothing = 10;
% Pxx_smooth_tmp = conv(ones([1 smoothing])./smoothing, Pxx);
% Pxx_smooth = Pxx_smooth_tmp(1:end-smoothing+1);
% figure; plot(freq-(fs/2), fftshift((Pxx_smooth)));

sym1 = ifft(fdd_mat(:,1));
sym2 = ifft(fdd_mat(:,2));
sym3 = ifft(fdd_mat(:,3));
sym4 = ifft(fdd_mat(:,4));
sym5 = ifft(fdd_mat(:,5));
sym6 = ifft(fdd_mat(:,6));

% each frequency window for ofdm is 64 samples long, modulated by its own distinct carrier
% 

% gen more complex random signals
order1= 16;
M = sqrt(order1);
tx_scm = (randi(M, 1, length(tx_syms)) - (M+1)/2) + i*(randi(M, 1, length(tx_syms)) - (M+1)/2);
tx_scm_vec = repelem(tx_scm, 8);

fs_scm = 5e6;
N_scm = length(tx_scm_vec);
t_scm = 1:1/fs_scm:5-(1/fs_scm);
freq_scm = 0:fs_scm/N_scm:fs_scm-(1/fs_scm);
freq_one_scm = freq_scm(1:N_scm/2+1);
freq_one(2:end-1);

figure;
plot(real(tx_scm_vec)); hold on;
plot(real(tx_scm_vec), 'o'); hold off;
Pxx_scm = (1/(N_scm^2))*abs(fft(tx_scm_vec)).^2;
Pxx_scm_one = Pxx_scm(1:N/2+1);
Pxx_scm_one(2:end-1) = 2*Pxx_scm_one(2:end-1);
figure; plot(freq_scm-(fs_scm/2), fftshift(10*log(Pxx_scm)));

sub_C = 3;
sub_N = floor(length(tx_syms)/sub_C);
fdd_scm_syms = (randi(M, 1, sub_N) - (M+1)/2) + (i*randi(M, 1, sub_N) - (M+1)/2);
fdd_scm_syms_up = circshift(upsample(fdd_scm_syms, sub_C),1);
fdd_scm_mat = reshape(fdd_scm_syms_up, sub_C, sub_N);
tdd_scm_mat = ifft(fdd_scm_syms, sub_C, 1);
tdd_scm_vec = reshape(tdd_scm_mat, 1, sub_C*length(tdd_scm_mat(1,:)));


fs_cpscm = 5e6;
N_cpscm = length(tdd_scm_vec);
t_cpscm = 0:1/fs_cpscm:5-(1/fs_cpscm);
freq_cpscm = 0:fs_cpscm/N_cpscm:fs_cpscm-(1/fs_cpscm);

P = (1/(N^2))*abs(fft(tdd_scm_vec)).^2;
P_one = P(1:N_cpscm/2+1);
P_one(2:end-1) = 2*P_one(2:end-1);
figure; plot(freq_cpscm-(fs_cpscm/2), fftshift(10*log(P)));








