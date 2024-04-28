dbg = 0
close all;
bar_arr = [];
%===================================================================
load('bbb_cpscm_ord2');
if dbg
 figure;
 subplot(211);
 plot(real(tx_vec_iris));
 subplot(212)
 plot(imag(tx_vec_iris));
end
CPSCM_FRAME_PAPR_2 = max((abs(tx_vec_iris)).^2)/mean((abs(tx_vec_iris)).^2)
CPSCM_FRAME_PAYLOAD_2 = max((abs(tx_payload_vec)).^2)/mean((abs(tx_payload_vec)).^2)
CPSCM_FRAME_PRE_2 = max((abs(preamble)).^2)/mean((abs(preamble)).^2)

bar_arr = [bar_arr CPSCM_FRAME_PRE_2 CPSCM_FRAME_PAYLOAD_2 CPSCM_FRAME_PAPR_2];

%===================================================================
load('bbb_cpscm_ord4');

if dbg
 figure;
 subplot(211);
 plot(real(tx_vec_iris));
 subplot(212)
 plot(imag(tx_vec_iris));
end
CPSCM_FRAME_PAPR_4 = max((abs(tx_vec_iris)).^2)/mean((abs(tx_vec_iris)).^2)
CPSCM_FRAME_PAYLOAD_4 = max((abs(tx_payload_vec)).^2)/mean((abs(tx_payload_vec)).^2)
CPSCM_FRAME_PRE_4 = max((abs(preamble)).^2)/mean((abs(preamble)).^2)

bar_arr = [bar_arr CPSCM_FRAME_PRE_4 CPSCM_FRAME_PAYLOAD_4 CPSCM_FRAME_PAPR_4];


%===================================================================
load('bbb_cpscm_ord16');

if dbg
 figure;
 subplot(211);
 plot(real(tx_vec_iris));
 subplot(212)
 plot(imag(tx_vec_iris));
end
CPSCM_FRAME_PAPR_16 = max((abs(tx_vec_iris)).^2)/mean((abs(tx_vec_iris)).^2)
CPSCM_FRAME_PAYLOAD_16 = max((abs(tx_payload_vec)).^2)/mean((abs(tx_payload_vec)).^2)
CPSCM_FRAME_PRE_16 = max((abs(preamble)).^2)/mean((abs(preamble)).^2)

bar_arr = [bar_arr CPSCM_FRAME_PRE_16 CPSCM_FRAME_PAYLOAD_16 CPSCM_FRAME_PAPR_16];

%===================================================================
load('bbb_cpscm_ord64');

if dbg
 figure;
 subplot(211);
 plot(real(tx_vec_iris));
 subplot(212)
 plot(imag(tx_vec_iris));
end
CPSCM_FRAME_PAPR_16 = max((abs(tx_vec_iris)).^2)/mean((abs(tx_vec_iris)).^2)
CPSCM_FRAME_PAYLOAD_16 = max((abs(tx_payload_vec)).^2)/mean((abs(tx_payload_vec)).^2)
CPSCM_FRAME_PRE_16 = max((abs(preamble)).^2)/mean((abs(preamble)).^2)

bar_arr = [bar_arr CPSCM_FRAME_PRE_16 CPSCM_FRAME_PAYLOAD_16 CPSCM_FRAME_PAPR_16];


%===================================================================
load('bbb_ofdm_ord2');
if dbg
 figure;
 subplot(211);
 plot(real(tx_vec_iris));
 subplot(212)
 plot(imag(tx_vec_iris));
end
OFDM_FRAME_PAPR_2 = max((abs(tx_vec_iris)).^2)/mean((abs(tx_vec_iris)).^2)
OFDM_FRAME_PAYLOAD_2 = max((abs(tx_payload_vec)).^2)/mean((abs(tx_payload_vec)).^2)
OFDM_FRAME_PRE_2 = max((abs(preamble)).^2)/mean((abs(preamble)).^2)

bar_arr = [bar_arr OFDM_FRAME_PRE_2 OFDM_FRAME_PAYLOAD_2 OFDM_FRAME_PAPR_2];

%===================================================================
load('bbb_ofdm_ord4');

if dbg
 figure;
 subplot(211);
 plot(real(tx_vec_iris));
 subplot(212)
 plot(imag(tx_vec_iris));
end
OFDM_FRAME_PAPR_4 = max((abs(tx_vec_iris)).^2)/mean((abs(tx_vec_iris)).^2)
OFDM_FRAME_PAYLOAD_4 = max((abs(tx_payload_vec)).^2)/mean((abs(tx_payload_vec)).^2)
OFDM_FRAME_PRE_4 = max((abs(preamble)).^2)/mean((abs(preamble)).^2)

bar_arr = [bar_arr OFDM_FRAME_PRE_4 OFDM_FRAME_PAYLOAD_4 OFDM_FRAME_PAPR_4];

%===================================================================
load('capture_all_ofdm_tx.mat');

if dbg
 figure;
 subplot(211);
 plot(real(tx_vec_iris));
 subplot(212)
 plot(imag(tx_vec_iris));
end
OFDM_FRAME_PAPR_16 = max((abs(tx_vec_iris)).^2)/mean((abs(tx_vec_iris)).^2)
OFDM_FRAME_PAYLOAD_16 = max((abs(tx_payload_vec)).^2)/mean((abs(tx_payload_vec)).^2)
OFDM_FRAME_PRE_16 = max((abs(preamble)).^2)/mean((abs(preamble)).^2)

bar_arr = [bar_arr OFDM_FRAME_PRE_16 OFDM_FRAME_PAYLOAD_16 OFDM_FRAME_PAPR_16];


%===================================================================
load('bbb_ofdm_ord64');

if dbg
 figure;
 subplot(211);
 plot(real(tx_vec_iris));
 subplot(212)
 plot(imag(tx_vec_iris));
end
OFDM_FRAME_PAPR_64 = max((abs(tx_vec_iris)).^2)/mean((abs(tx_vec_iris)).^2)
OFDM_FRAME_PAYLOAD_64 = max((abs(tx_payload_vec)).^2)/mean((abs(tx_payload_vec)).^2)
OFDM_FRAME_PRE_64 = max((abs(preamble)).^2)/mean((abs(preamble)).^2)

bar_arr = [bar_arr OFDM_FRAME_PRE_64 OFDM_FRAME_PAYLOAD_64 OFDM_FRAME_PAPR_64];

figure;
bar(bar_arr);

%OFDM Preamble 2    OFDM Preamble 4    OFDM Preamble 16  OFDM Preamble 64
%OFDM Payload  2    OFDM Payload  4    OFDM Payload 16   OFDM Payload 64
%OFDM Frame 2       OFDM Frame 4       OFDM Frame 16     OFDM Frame 64
%CPSCM Preamble 2   CPSCM Preamble 4   CPSCM Preamble 16 CPSCM Preamble 64
%CPSCM Payload 2    CPSCM Payload 4    CPSCM Payload 16  CPSCM Payload 64
%CPSCM Frame 2      CPSCM Frame 4      CPSCM Frame 16    CPSCM Frame 64


somenames = {'OFDM PRE M = 2', 'OFDM PAY M = 2', 'OFDM FRM M = 2', 'CPSCM PRE M = 2', 'CPSCM PAY M = 2', 'CPSCM FRM M = 2', ...
             'OFDM PRE M = 4', 'OFDM PAY M = 4', 'OFDM FRM M = 4', 'CPSCM PRE M = 4', 'CPSCM PAY M = 4', 'CPSCM FRM M = 4', ...
             'OFDM PRE M = 16','OFDM PAY M = 16','OFDM FRM M = 16','CPSCM PRE M = 16','CPSCM PAY M = 16','CPSCM FRM M = 16', ...
             'OFDM PRE M = 64','OFDM PAY M = 64','OFDM FRM M = 64','CPSCM PRE M = 64','CPSCM PAY M = 64','CPSCM FRM M = 64'}; 

yticks = 1:length(bar_arr);


%set(gca,'YTick',[1:length(bar_arr)], 'yticklabel',somenames)
%set(gca, 'ydir', 'reverse', 'YTick',[1:length(bar_arr)], 'yticklabel',somenames)
grid on;
ylabel("PAPR %")
set(gca, 'XTickLabel',{'CS0','CS10','CS20'}, 'XTick',[1:length(bar_arr)], 'xticklabel',somenames)
title('Measured PAPR for OFDM and CPSCM  of order M = 2, 4, 16, 64 (Preamble, Payload and Whole Frame)')




%set(gca, 'XTickLabel',{'CS0','CS10','CS20'})
