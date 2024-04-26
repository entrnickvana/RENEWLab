%Power level
%Mod order/type
%Sym Errors
%Bit Errors
%EVM
%SNR
%PAPR
%Channel Estimate

%TX_GN_EXT_ARR = [70:2:100];
TX_GN_EXT_ARR = [70:10:100];
APPLY_CFO_CORRECTION_EXT = 
N_OFDM_SYM_EXT = 30;
MOD_ORDER_EXT = 16;
N_FRM_EXT = 1;
PLOT_EXT = 0;
DO_APPLY_PHASE_ERR_CORRECTION_EXT = 0;

% is array of column vectors
%rx_vec_iris_arr = [];
%tx_gn_UE = [];
%m_order_arr = [];
%sym_err_arr = [];
%bit_err_arr = [];
%evm_arr = [];
%snr_arr = [];
%papr_arr = [];
%ch_est = [];
%p_ph_err_arr = [];


%TX_GN_EXT =

for ii = 1:length(TX_GN_EXT_ARR)
    
  TX_GN_EXT = TX_GN_EXT_ARR(ii);
    
  rl_ofdm_siso_auto
  rx_vec_iris_arr = [rx_vec_iris_arr rx_vec_iris]
  papr = max((abs(rx_vec_iris)).^2)/mean((abs(rx_vec_iris)).^2)

  sym_err_arr = [ sym_err_arr];
  bit_err_arr = [ bit_err_arr bit_errs];
  evm_arr     = [ evm_arr aevms];
  snr_arr     = [ snr_arr snr];
  papr_arr    = [ papr_arr papr];
  
end



