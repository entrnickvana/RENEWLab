%Power level
%Mod order/type
%Sym Errors
%Bit Errors
%EVM
%SNR
%PAPR
%Channel Estimate

%TX_GN_EXT_ARR = [70:2:100];
N_REP = 5;
TX_GN_EXT_ARR = repelem([70:10:100], 1, N_REP);
APPLY_CFO_CORRECTION_EXT = 1;
N_OFDM_SYM_EXT = 30;
MOD_ORDER_EXT = 16;
N_FRM_EXT = 1;
PLOT_EXT = 0;
DO_APPLY_PHASE_ERR_CORRECTION_EXT = 0;

% is array of column vectors
rx_vec_iris_arr = [];
tx_gn_UE_arr = [];
m_order_arr = [];
sym_err_arr = [];
bit_err_arr = [];
evm_arr = [];
snr_arr = [];
papr_arr = [];

% col vect 64
ch_est_arr = [];
%p_ph_err_arr = [];

%TX_GN_EXT =

% fprintf('\n Frame %d Results:\n', frm_idx);
% fprintf('Transmission Mode: %s \n', tx_direction);
% fprintf('Num Bytes:   %d\n', N_DATA_SYMS * log2(MOD_ORDER) / 8);
% fprintf('Sym Errors:  %d (of %d total symbols)\n', sym_errs, N_DATA_SYMS);
% fprintf('Bit Errors:  %d (of %d total bits)\n', bit_errs, N_DATA_SYMS * log2(MOD_ORDER));
% fprintf('Avg. EVM: %f%% \n', 100*aevms);

figure;
hold on;
for ii = 1:length(TX_GN_EXT_ARR)
    
  TX_GN_EXT = TX_GN_EXT_ARR(ii);
    
  rl_ofdm_siso_auto
  rx_vec_iris_arr = [rx_vec_iris_arr rx_vec_iris];
  papr = max((abs(rx_vec_iris)).^2)/mean((abs(rx_vec_iris)).^2);

  tx_gn_UE_arr = [tx_gn_UE_arr TX_GN_EXT];  
  m_order_arr = [m_order_arr MOD_ORDER_EXT];
  sym_err_arr = [sym_err_arr sym_errs];
  bit_err_arr = [bit_err_arr bit_errs];
  evm_arr     = [evm_arr aevms];
  snr_arr     = [snr_arr snr];
  papr_arr    = [papr_arr papr];
  ch_est_arr  = [ch_est_arr];

  scatter(snr, bit_errs/N_DATA_SYMS * log2(MOD_ORDER);
  
end



