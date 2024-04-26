%Power level
%Mod order/type
%Sym Errors
%Bit Errors
%EVM
%SNR
%PAPR

%TX_GN_EXT_ARR = [70:2:100];
TX_GN_EXT_ARR = [70:10:100];
APPLY_CFO_CORRECTION_EXT = 
N_OFDM_SYM_EXT = 30;
MOD_ORDER_EXT = 16;
N_FRM_EXT = 1;
PLOT_EXT = 0;
DO_APPLY_PHASE_ERR_CORRECTION_EXT = 0;

TX_GN_EXT =

for ii = TX_GN_EXT_ARR
    
  TX_GN_EXT = TX_GN_EXT_ARR(ii);
    
  rl_ofdm_siso_auto
  
end



