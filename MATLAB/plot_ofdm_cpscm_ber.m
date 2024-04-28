%Power level
%Mod order/type
%Sym Errors
%Bit Errors
%EVM
%SNR
%PAPR
%Channel Estimate

% close all;
clear all;

% ==================== OFDM SWEEP =====================================
load('ber.mat');

%TX_GN_EXT_ARR = [70:2:100];
N_REP = 5;
TX_GN_EXT_ARR = repelem([70:2:100+1], 1, N_REP);
APPLY_CFO_CORRECTION_EXT = 1;
N_OFDM_SYM_EXT = 30;
MOD_ORDER_EXT_ARR = [2 4 16];
MOD_ORDER_EXT = 16;
N_FRM_EXT = 5;
PLOT_EXT = 0;
DO_APPLY_PHASE_ERR_CORRECTION_EXT = 0;
N_DATA_SYMS = 48*30;


figure;

%bpsk_bit = 10*log10(bit_err_arr(m_order_arr == 2));
%qpsk_bit = 10*log10(bit_err_arr(m_order_arr == 4));
%qam16_bit = 10*log10(bit_err_arr(m_order_arr == 16));
%
%figure;
%scatter(snr_arr(m_order_arr == 2), bpsk_bit/(N_DATA_SYMS * log2(2)), 'r*'); hold on;
%scatter(snr_arr(m_order_arr == 4), qpsk_bit/(N_DATA_SYMS * log2(4)), 'bl*');
%scatter(snr_arr(m_order_arr == 16), qam16_bit/(N_DATA_SYMS * log2(16)), 'g*');


bpsk_bit = bit_err_arr(m_order_arr == 2);
qpsk_bit = bit_err_arr(m_order_arr == 4);
qam16_bit = bit_err_arr(m_order_arr == 16);

bpsk_ave = mean(snr_arr([m_order_arr == 2] & [bit_err_arr == 0]));
qpsk_ave = mean(snr_arr([m_order_arr == 4] & [bit_err_arr == 0]));
qam16_ave = mean(snr_arr([m_order_arr == 16] & [bit_err_arr == 0]));

%snr_arr([m_order_arr == 2] & [bit_err_arr == 0]) = bpsk_ave;
%snr_arr([m_order_arr == 4] & [bit_err_arr == 0]) = qpsk_ave;
%snr_arr([m_order_arr == 16] & [bit_err_arr == 0]) = qam16_ave;
%qpsk_ave = mean(snr_arr(m_order_arr == 4))
%qam16_ave = mean(snr_arr(m_order_arr == 16))

%bpsk_bit(bpsk_bit == 0) = 1e-2;
%qpsk_bit(qpsk_bit == 0) = 1e-2;
%qam16_bit(qam16_bit == 0) = 1e-2;

%snr_arr([bpsk_bit == 0].*[m_order_arr == 2])  = ones(1, length(m_order_arr(m_order_arr == 2)))*mean(snr_arr([bpsk_bit == 0].*[m_order_arr == 2]));
%snr_arr([qpsk_bit == 0].*[m_order_arr == 4])  = ones(1, length(m_order_arr(m_order_arr == 4)))*mean(snr_arr([qpsk_bit == 0].*[m_order_arr == 4]));
%snr_arr([bpsk_bit == 0].*[m_order_arr == 16])  = ones(1, length(m_order_arr(m_order_arr == 16)))*mean(snr_arr([qam16_bit == 0].*[m_order_arr == 16]));


%bpsk_bit(bpsk_bit == 0) = mean(snr_arr(bpsk_bit == 0));
%qpsk_bit(qpsk_bit == 0) = mean(snr_arr(qpsk_bit == 0));
%qam16_bit(qam16_bit == 0) = mean(snr_arr(qam16_bit == 0));

ber_floor = 1e-1;

figure;
scatter(snr_arr(m_order_arr == 2), 10*log10(bpsk_bit/(N_DATA_SYMS * log2(2))), 'r*'); hold on;
scatter(snr_arr(m_order_arr == 4), 10*log10(qpsk_bit/(N_DATA_SYMS * log2(4))), 'bl*');
scatter(snr_arr(m_order_arr == 16), 10*log10(qam16_bit/(N_DATA_SYMS * log2(16))), 'g*');
scatter(bpsk_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(2))), 'r*');
scatter(qpsk_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(4))), 'bl*');
scatter(qam16_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(16))), 'g*');

figure;
scatter(snr_arr(m_order_arr == 2), 10*log10(bpsk_bit/(N_DATA_SYMS * log2(2))), 'r*'); hold on;
scatter(snr_arr(m_order_arr == 4), 10*log10(qpsk_bit/(N_DATA_SYMS * log2(4))), 'bl*');
scatter(snr_arr(m_order_arr == 16), 10*log10(qam16_bit/(N_DATA_SYMS * log2(16))), 'g*');
scatter(bpsk_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(2))), 'r*');
scatter(qpsk_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(4))), 'bl*');
scatter(qam16_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(16))), 'g*');




%ofdm_bpsk_bit_err = bit_err_arr(m_order_arr == 2)/(N_DATA_SYMS*log2(2));
%%ofdm_bpsk_bit_err(ofdm_bpsk_bit_err == -Inf) = 1e-3;
%ofdm_bpsk_bit_err = 10*log10(ofdm_bpsk_bit_err);
%
%ofdm_qpsk_bit_err = bit_err_arr(m_order_arr == 4)/(N_DATA_SYMS*log2(4));
%%ofdm_qpsk_bit_err(ofdm_qpsk_bit_err == -Inf) = 1e-3;
%ofdm_qsk_bit_err = 10*log10(ofdm_qpsk_bit_err);
%
%ofdm_16qam_bit_err = bit_err_arr(m_order_arr == 16)/(N_DATA_SYMS*log2(16));
%%ofdm_16qam_bit_err(ofdm_16qam_bit_err == -Inf) = 1e-3;
%ofdm_16qam_bit_err = 10*log10(ofdm_16qam_bit_err);

%scatter(snr_arr(m_order_arr == 2), ofdm_bpsk_bit_err, 'r*'); hold on;
%scatter(snr_arr(m_order_arr == 4), ofdm_qpsk_bit_err, 'bl*');
%scatter(snr_arr(m_order_arr == 16), ofdm_16qam_bit_err, 'g*');

% ==================== OFDM SWEEP =====================================
load('cpscm_cap.mat');

%TX_GN_EXT_ARR = [70:2:100];
N_REP = 5;
TX_GN_EXT_ARR = repelem([70:2:100+1], 1, N_REP);
APPLY_CFO_CORRECTION_EXT = 1;
N_OFDM_SYM_EXT = 30;
MOD_ORDER_EXT_ARR = [2 4 16];
MOD_ORDER_EXT = 16;
N_FRM_EXT = 5;
PLOT_EXT = 0;
DO_APPLY_PHASE_ERR_CORRECTION_EXT = 0;
N_DATA_SYMS = 30;

ber_floor = 1e-1;


bpsk_bit = bit_err_arr(m_order_arr == 2);
qpsk_bit = bit_err_arr(m_order_arr == 4);
qam16_bit = bit_err_arr(m_order_arr == 16);

bpsk_ave = mean(snr_arr([m_order_arr == 2] & [bit_err_arr == 0]));
qpsk_ave = mean(snr_arr([m_order_arr == 4] & [bit_err_arr == 0]));
qam16_ave = mean(snr_arr([m_order_arr == 16] & [bit_err_arr == 0]));


scatter(snr_arr(m_order_arr == 2), 10*log10(bpsk_bit/(N_DATA_SYMS * log2(2))), 'm*'); hold on;
scatter(snr_arr(m_order_arr == 4), 10*log10(qpsk_bit/(N_DATA_SYMS * log2(4))), 'c*');
scatter(snr_arr(m_order_arr == 16), 10*log10(qam16_bit/(N_DATA_SYMS * log2(16))), 'k*');
scatter(bpsk_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(2))), 'm*');
scatter(qpsk_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(4))), 'c*');
scatter(qam16_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(16))), 'k*');

figure;

scatter(snr_arr(m_order_arr == 2), 10*log10(bpsk_bit/(N_DATA_SYMS * log2(2))), 'm*'); hold on;
scatter(snr_arr(m_order_arr == 4), 10*log10(qpsk_bit/(N_DATA_SYMS * log2(4))), 'c*');
scatter(snr_arr(m_order_arr == 16), 10*log10(qam16_bit/(N_DATA_SYMS * log2(16))), 'k*');
scatter(bpsk_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(2))), 'm*');
scatter(qpsk_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(4))), 'c*');
scatter(qam16_ave, 10*log10(ber_floor/(N_DATA_SYMS * log2(16))), 'k*');


