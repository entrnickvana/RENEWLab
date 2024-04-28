

clear all;
close all;
load('tx_payload_vec_scm_single.mat');
tx_payload_vec_scm_single = tx_payload_vec_scm;
%load('tx_payload_vec_scm_double_offset.mat');
load('tx_payload_vec_scm_double_offset1.mat');
load('tx_payload_vec_scm_double.mat');
load('tx_vec_payload_for_intro.mat');
load('tx_vec_payload_scm_for_intro.mat');


idx = [2:7 9:21 23:27 39:43 45:57 59:64];
xf_ofdm = zeros(1, 64);
xf_ofdm(idx) = randi(16, 1, length(idx));
xt_ofdm = ifft(xf_ofdm, 64);
xt_ofdm_window = [zeros(1, 64) xt_ofdm zeros(1, 64)];

xf_cpscm_pos = [0 1 zeros(1, 64-2)];
xt_cpscm_pos = ifft(xf_cpscm_pos, 64);
xf_cpscm_pos_window = [zeros(1, 64) xt_cpscm_pos zeros(1, 64)];

xf_cpscm_neg = [zeros(1, 64-2) 0 1];
xt_cpscm_neg = ifft(xf_cpscm_neg, 64);
xf_cpscm_neg_window = [zeros(1, 64) xt_cpscm_neg zeros(1, 64)];

xf_ofdm_tx = zeros(64,64);
xf_ofdm_tx(idx, :) = randi(16,length(idx), 64);
xt_ofdm_tx_mat = ifft(xf_ofdm_tx, 64, 2);
xt_ofdm_tx_vec = reshape(xt_ofdm_tx_mat, numel(xt_ofdm_tx_mat), 1);

PAPR_ofdm = max((abs(tx_payload_vec)).^2)/mean((abs(tx_payload_vec)).^2)
PAPR_single = max((abs(tx_payload_vec_scm_single)).^2)/mean((abs(tx_payload_vec_scm_single)).^2)
PAPR_double = max((abs(tx_payload_vec_scm_double)).^2)/mean((abs(tx_payload_vec_scm_double)).^2)
PAPR_double_offset = max((abs(tx_payload_vec_scm_double_offset1)).^2)/mean((abs(tx_payload_vec_scm_double_offset1)).^2)

xf_cpscm_128 = [0 1 zeros(1, 128-2)];
xt_cpscm_128 = ifft(xf_cpscm_128, 128);
xt_cpscm_128_window = [zeros(1,128) xt_cpscm_128 zeros(1, 128)];

cpscm_single_sided_80Msps = repmat(tx_payload_vec_scm_single, 1, 30);
cpscm_doubld_sided_80Msps = repmat(tx_payload_vec_scm_double, 1, 30);
ofdm_5Msps = repmat(tx_payload_vec, 1, 30);

