#!/usr/bin/python3
"""
 hdfDump.py

 Plotting from HDF5 file
 Script to analyze recorded hdf5 file from channel sounding (see Sounder/).
 Usage format is:
    ./hdfDump.py <hdf5_file_name> <frame_to_plot (optional, default=100)>

 Example:
    ./hdfDump.py ../Sounder/logs/test-hdf5.py 150


 Author(s): Oscar Bejarano: obejarano@rice.edu
            Rahman Doost-Mohamamdy: doost@rice.edu

---------------------------------------------------------------------
 Copyright © 2018-2019. Rice University.
 RENEW OPEN SOURCE LICENSE: http://renew-wireless.org/license
---------------------------------------------------------------------
"""

import sys
import struct
import numpy as np
import os
import math
import h5py
import time
import datetime
import logging
import matplotlib.pyplot as plt
import pdb
import collections
from channel_analysis import *
from detect_peaks import detect_peaks


class hdfDump:

    def __init__(self, filename):
        self.h5file = None
        self.filename = filename
        self.h5struct = []
        self.data = []
        self.metadata = {}
        self.samples = {}

    def get_hdf5(self):
        """
        Get the most recent log file, open it if necessary.
        """
        if (not self.h5file) or (self.filename != self.h5file.filename):
            # if it's closed, e.g. for the C version, open it
            print('Opening %s...' % self.filename)
            try:
                self.h5file = h5py.File(self.filename, 'r')
            except OSError:
                print("File not found. Terminating program now")
                sys.exit(0)
        # return self.h5file

    def parse_hdf5(self):
        """
        Parse file to retrieve metadata and data.
        HDF5 file has been written in DataRecorder.cpp (in Sounder folder)

        Output:
            Data (hierarchy):
                -Path
                -Pilot_Samples
                    --Samples
                -UplinkData
                    --Samples
                -Attributes
                        {FREQ, RATE, SYMBOL_LEN_NO_PAD, PREFIX_LEN, POSTFIX_LEN, SYMBOL_LEN, FFT_SIZE, CP_LEN,
                        BEACON_SEQ_TYPE, PILOT_SEQ_TYPE, BS_HUB_ID, BS_SDR_NUM_PER_CELL, BS_SDR_ID, BS_NUM_CELLS,
                        BS_CH_PER_RADIO, BS_FRAME_SCHED, BS_RX_GAIN_A, BS_TX_GAIN_A, BS_RX_GAIN_B, BS_TX_GAIN_B,
                        BS_BEAMSWEEP, BS_BEACON_ANT, BS_NUM_ANT, BS_FRAME_LEN, CL_NUM, CL_CH_PER_RADIO, CL_AGC_EN,
                        CL_RX_GAIN_A, CL_TX_GAIN_A, CL_RX_GAIN_B, CL_TX_GAIN_B, CL_FRAME_SCHED, CL_SDR_ID,
                        CL_MODULATION, UL_SYMS}

        Dimensions of input sample data (as shown in DataRecorder.cpp in Sounder):
            - Pilots
                dims_pilot[0] = maxFrame
                dims_pilot[1] = number of cells
                dims_pilot[2] = number of UEs
                dims_pilot[3] = number of antennas (at BS)
                dims_pilot[4] = samples per symbol * 2 (IQ)

            - Uplink Data
                dims_data[0] = maxFrame
                dims_data[1] = number of cells
                dims_data[2] = uplink symbols per frame
                dims_data[3] = number of antennas (at BS)
                dims_data[4] = samples per symbol * 2 (IQ)
        """
        g = self.h5file
        prefix = ''
        self.data = collections.defaultdict(lambda: collections.defaultdict(dict))

        for key in g.keys():
            item = g[key]
            path = '{}/{}'.format(prefix, key)
            keys = [i for i in item.keys()]
            if isinstance(item[keys[0]], h5py.Dataset):  # test for dataset
                # Path
                self.data['path'] = path
                # Attributes
                for attribute in item.attrs.keys():
                    # Store attributes
                    self.data['Attributes'][attribute] = item.attrs[attribute]
                # Pilot and UplinkData Samples
                for k in keys:
                    if not isinstance(item[k], h5py.Group):
                        # dataset = np.array(item[k].value)  # dataset.value has been deprecated. dataset[()] instead
                        dataset = np.array(item[(k)])

                        if type(dataset) is np.ndarray:
                            if dataset.size != 0:
                                if type(dataset[0]) is np.bytes_:
                                    dataset = [a.decode('ascii') for a in dataset]

                        # Store samples
                        self.data[k]['Samples'] = dataset

                    # for attribute in item[k].attrs.keys():
                        # # Store attributes
                        # self.data[k]['Attributes'][attribute] = item[k].attrs[attribute]

            else:
                raise Exception("No datasets found")

        return self.data

    def get_attributes(self):
        # Retrieve attributes, translate into python dictionary
        data = self.data

        # Check if attributes are there
        client_id = data['Attributes']['CL_SDR_ID'].astype(str)
        if client_id.size == 0:
            cl_present = False
            print('Client information not present. It is likely the client was run separately')
        else:
            cl_present = True

        bs_id = data['Attributes']['BS_SDR_ID'].astype(str)
        if bs_id.size == 0:
            raise Exception('Base Station information not present')

        # Data cleanup
        # In OFDM_DATA_CLx and OFDM_PILOT, we have stored both real and imaginary in same vector
        # (i.e., RE1,IM1,RE2,IM2...REm,IM,)
        # Pilots
        pilot_vec = data['Attributes']['OFDM_PILOT']
        # some_list[start:stop:step]
        I = pilot_vec[0::2]
        Q = pilot_vec[1::2]
        pilot_complex = I + Q * 1j

        if cl_present:
            # Time-domain OFDM data
            num_cl = np.squeeze(data['Attributes']['CL_NUM'])
            ofdm_data_time = []  # np.zeros((num_cl, 320)).astype(complex)
            for clIdx in range(num_cl):
                this_str = 'OFDM_DATA_TIME_CL' + str(clIdx)
                data_per_cl = np.squeeze(data['Attributes'][this_str])
                # some_list[start:stop:step]
                if np.any(data_per_cl):
                    # If data present
                    I = np.double(data_per_cl[0::2])
                    Q = np.double(data_per_cl[1::2])
                    IQ = I + Q * 1j
                    ofdm_data_time.append(IQ)

            # Frequency-domain OFDM data
            ofdm_data = []  # np.zeros((num_cl, 320)).astype(complex)
            for clIdx in range(num_cl):
                this_str = 'OFDM_DATA_CL' + str(clIdx)
                data_per_cl = np.squeeze(data['Attributes'][this_str])
                # some_list[start:stop:step]
                if np.any(data_per_cl):
                    # If data present
                    I = np.double(data_per_cl[0::2])
                    Q = np.double(data_per_cl[1::2])
                    IQ = I + Q * 1j
                    ofdm_data.append(IQ)

            # Populate dictionary
            self.metadata = {
                'CLIENT_PRESENT': cl_present,
                'FREQ': np.squeeze(data['Attributes']['FREQ']),
                'RATE': np.squeeze(data['Attributes']['RATE']),
                'SYM_LEN_NO_PAD': np.squeeze(data['Attributes']['SYMBOL_LEN_NO_PAD']),
                'PREFIX_LEN': np.squeeze(data['Attributes']['PREFIX_LEN']),
                'POSTFIX_LEN': np.squeeze(data['Attributes']['POSTFIX_LEN']),
                'SYM_LEN': np.squeeze(data['Attributes']['SYMBOL_LEN']),
                'FFT_SIZE': np.squeeze(data['Attributes']['FFT_SIZE']),
                'CP_LEN': np.squeeze(data['Attributes']['CP_LEN']),
                'BEACON_SEQ': np.squeeze(data['Attributes']['BEACON_SEQ_TYPE']).astype(str),
                'PILOT_SEQ': np.squeeze(data['Attributes']['PILOT_SEQ_TYPE']).astype(str),
                'BS_HUB_ID': np.squeeze(data['Attributes']['BS_HUB_ID']).astype(str),
                'BS_SDR_NUM_PER_CELL': np.squeeze(data['Attributes']['BS_SDR_NUM_PER_CELL']).astype(int),
                'BS_SDR_ID': np.squeeze(data['Attributes']['BS_SDR_ID']).astype(str),
                'BS_NUM_CELLS': np.squeeze(data['Attributes']['BS_NUM_CELLS']),
                'BS_CH_PER_RADIO': np.squeeze(data['Attributes']['BS_CH_PER_RADIO']),
                'BS_FRAME_SCHED': np.squeeze(data['Attributes']['BS_FRAME_SCHED']).astype(str),
                'BS_RX_GAIN_A': np.squeeze(data['Attributes']['BS_RX_GAIN_A']),
                'BS_TX_GAIN_A': np.squeeze(data['Attributes']['BS_TX_GAIN_A']),
                'BS_RX_GAIN_B': np.squeeze(data['Attributes']['BS_RX_GAIN_B']),
                'BS_TX_GAIN_B': np.squeeze(data['Attributes']['BS_TX_GAIN_B']),
                'BS_BEAMSWEEP': np.squeeze(data['Attributes']['BS_BEAMSWEEP']),
                'BS_BEACON_ANT': np.squeeze(data['Attributes']['BS_BEACON_ANT']),
                'BS_NUM_ANT': np.squeeze(data['Attributes']['BS_NUM_ANT']),
                'BS_FRAME_LEN': np.squeeze(data['Attributes']['BS_FRAME_LEN']),
                'NUM_CLIENTS': np.squeeze(data['Attributes']['CL_NUM']),
                'CL_CH_PER_RADIO': np.squeeze(data['Attributes']['CL_CH_PER_RADIO']),
                'CL_AGC_EN': np.squeeze(data['Attributes']['CL_AGC_EN']),
                'CL_RX_GAIN_A': np.squeeze(data['Attributes']['CL_RX_GAIN_A']),
                'CL_TX_GAIN_A': np.squeeze(data['Attributes']['CL_TX_GAIN_A']),
                'CL_RX_GAIN_B': np.squeeze(data['Attributes']['CL_RX_GAIN_B']),
                'CL_TX_GAIN_B': np.squeeze(data['Attributes']['CL_TX_GAIN_B']),
                'CL_FRAME_SCHED': np.squeeze(data['Attributes']['CL_FRAME_SCHED']).astype(str),
                'CL_SDR_ID': np.squeeze(data['Attributes']['CL_SDR_ID']).astype(str),
                'CL_MODULATION': np.squeeze(data['Attributes']['CL_MODULATION']).astype(str),
                'UL_SYMS': np.squeeze(data['Attributes']['UL_SYMS']),
                'OFDM_DATA_SC': np.squeeze(data['Attributes']['OFDM_DATA_SC']),
                'OFDM_PILOT_SC': np.squeeze(data['Attributes']['OFDM_PILOT_SC']),
                'OFDM_PILOT_SC_VALS': np.squeeze(data['Attributes']['OFDM_PILOT_SC_VALS']),
                'OFDM_PILOT_TIME': pilot_complex,
                'OFDM_DATA': ofdm_data,
                'OFDM_DATA_TIME': ofdm_data_time,
            }

        else:
            # Client not present
            # Populate dictionary
            self.metadata = {
                'CLIENT_PRESENT': cl_present,
                'FREQ': np.squeeze(data['Attributes']['FREQ']),
                'RATE': np.squeeze(data['Attributes']['RATE']),
                'SYM_LEN_NO_PAD': np.squeeze(data['Attributes']['SYMBOL_LEN_NO_PAD']),
                'PREFIX_LEN': np.squeeze(data['Attributes']['PREFIX_LEN']),
                'POSTFIX_LEN': np.squeeze(data['Attributes']['POSTFIX_LEN']),
                'SYM_LEN': np.squeeze(data['Attributes']['SYMBOL_LEN']),
                'FFT_SIZE': np.squeeze(data['Attributes']['FFT_SIZE']),
                'CP_LEN': np.squeeze(data['Attributes']['CP_LEN']),
                'BEACON_SEQ': np.squeeze(data['Attributes']['BEACON_SEQ_TYPE']).astype(str),
                'PILOT_SEQ': np.squeeze(data['Attributes']['PILOT_SEQ_TYPE']).astype(str),
                'BS_HUB_ID': np.squeeze(data['Attributes']['BS_HUB_ID']).astype(str),
                'BS_SDR_NUM_PER_CELL': np.squeeze(data['Attributes']['BS_SDR_NUM_PER_CELL']).astype(int),
                'BS_SDR_ID': np.squeeze(data['Attributes']['BS_SDR_ID']).astype(str),
                'BS_NUM_CELLS': np.squeeze(data['Attributes']['BS_NUM_CELLS']),
                'BS_CH_PER_RADIO': np.squeeze(data['Attributes']['BS_CH_PER_RADIO']),
                'BS_FRAME_SCHED': np.squeeze(data['Attributes']['BS_FRAME_SCHED']).astype(str),
                'BS_RX_GAIN_A': np.squeeze(data['Attributes']['BS_RX_GAIN_A']),
                'BS_TX_GAIN_A': np.squeeze(data['Attributes']['BS_TX_GAIN_A']),
                'BS_RX_GAIN_B': np.squeeze(data['Attributes']['BS_RX_GAIN_B']),
                'BS_TX_GAIN_B': np.squeeze(data['Attributes']['BS_TX_GAIN_B']),
                'BS_BEAMSWEEP': np.squeeze(data['Attributes']['BS_BEAMSWEEP']),
                'BS_BEACON_ANT': np.squeeze(data['Attributes']['BS_BEACON_ANT']),
                'BS_NUM_ANT': np.squeeze(data['Attributes']['BS_NUM_ANT']),
                'BS_FRAME_LEN': np.squeeze(data['Attributes']['BS_FRAME_LEN']),
                'NUM_CLIENTS': np.squeeze(data['Attributes']['CL_NUM']),
                'CL_MODULATION': np.squeeze(data['Attributes']['CL_MODULATION']).astype(str),
                'UL_SYMS': np.squeeze(data['Attributes']['UL_SYMS']),
                'OFDM_DATA_SC': np.squeeze(data['Attributes']['OFDM_DATA_SC']),
                'OFDM_PILOT_SC': np.squeeze(data['Attributes']['OFDM_PILOT_SC']),
                'OFDM_PILOT_SC_VALS': np.squeeze(data['Attributes']['OFDM_PILOT_SC_VALS']),
                'OFDM_PILOT_TIME': pilot_complex,
            }

    def get_samples(self, data_types_avail):
        # Retrieve samples, translate into python dictionary
        samples_pilots = []
        samples_ulData = []
        for idx, ftype in enumerate(data_types_avail):
            if ftype == "PILOTS":
                samples = self.data['Pilot_Samples']['Samples']
                samples_pilots = samples

            elif ftype == "UL_DATA":
                samples = self.data['UplinkData']['Samples']
                samples_ulData = samples

        self.samples = {'PILOT_SAMPS': samples_pilots,
                        'UL_SAMPS': samples_ulData,
                        }

    def verify_hdf5(self, default_frame=100):
        """
        Plot data in file to verify contents.

        Input:
            default_frame: Index of frame to be plotted. Default to frame #100
        """
        plt.close("all")

        data = self.data

        # Check which data we have available
        data_types_avail = []
        pilots_avail = bool(data['Pilot_Samples'])
        ul_data_avail = bool(data['UplinkData'])
        offset = int(np.squeeze(data['Attributes']['PREFIX_LEN']))

        if pilots_avail:
            data_types_avail.append("PILOTS")
            print("PILOT Data Available")
        if ul_data_avail:
            data_types_avail.append("UL_DATA")
            print("Uplink Data Available")

        # Empty structure
        if not data_types_avail:
            raise Exception(' **** No pilots or uplink data found **** ')

        # Retrieve attributes
        freq = np.squeeze(data['Attributes']['FREQ'])
        rate = np.squeeze(data['Attributes']['RATE'])
        symbol_length = np.squeeze(data['Attributes']['SYMBOL_LEN'])
        num_cl = np.squeeze(data['Attributes']['CL_NUM'])

        # PLOTTER
        # Plot pilots or data or both
        fig, axes = plt.subplots(nrows=6, ncols=len(data_types_avail), squeeze=False)
        for idx, ftype in enumerate(data_types_avail):
            if ftype == "PILOTS":
                axes[0, idx].set_title('PILOTS - Cell 0')
                samples = data['Pilot_Samples']['Samples']
                num_cl_tmp = num_cl  # number of UEs to plot data for

            elif ftype == "UL_DATA":
                axes[0, idx].set_title('UPLINK DATA - Cell 0')
                samples = data['UplinkData']['Samples']
                num_cl_tmp = 1  # number of UEs to plot data for

            # Compute CSI from IQ samples
            # Samps: #Frames, #Cell, #Users, #Pilot Rep, #Antennas, #Samples
            # CSI:   #Frames, #Cell, #Users, #Pilot Rep, #Antennas, #Subcarrier
            # For correlation use a fft size of 64
            csi, samps = samps2csi(samples, num_cl_tmp, symbol_length, fft_size=64, offset=offset, bound=0, cp=0)

            # Correlation (Debug plot useful for checking sync)
            amps = np.mean(np.abs(samps[:, 0, 0, 0, 0, :]), axis=1)
            pilot_frames = [i for i in range(len(amps)) if amps[i] > 0.01]
            ref_frame = pilot_frames[len(pilot_frames) // 2]
            cellCSI = csi[:, 0, :, :, :, :]     # First cell
            userCSI = np.mean(cellCSI[:, :, :, :, :], 2)
            corr_total, sig_sc = calCorr(userCSI, np.transpose(np.conj(userCSI[ref_frame, :, :, :]), (1, 0, 2)))
            best_frames = [i for i in pilot_frames if corr_total[i, 0] > 0.99]
            good_frames = [i for i in pilot_frames if corr_total[i, 0] > 0.95]
            bad_frames = [i for i in pilot_frames if corr_total[i, 0] > 0.9 and corr_total[i, 0] <= 0.94]
            worst_frames = [i for i in pilot_frames if corr_total[i, 0] < 0.9]
            print("Good frames len: %d" % len(pilot_frames))
            print("Amplitude of reference frame %d is %f" % (ref_frame, amps[ref_frame]))
            print("num of best frames %d" % len(best_frames))
            print("num of good frames %d" % len(good_frames))
            print("num of bad frames   %d" % len(bad_frames))
            print("num of worst frames   %d" % len(worst_frames))

            # Compute CSI from IQ samples
            # Samps: #Frames, #Cell, #Users, #Pilot Rep, #Antennas, #Samples
            # CSI:   #Frames, #Cell, #Users, #Pilot Rep, #Antennas, #Subcarrier
            # For looking at the whole picture, use a fft size of whole symbol_length as fft window (for visualization),
            # and no offset
            csi, samps = samps2csi(samples, num_cl_tmp, symbol_length, fft_size=symbol_length, offset=0, bound=0, cp=0)

            # Verify default_frame does not exceed max number of collected frames
            frame_to_plot = min(default_frame, samps.shape[0])

            # Plotter
            # Samps Dimensions: (Frame, Cell, User, Pilot Rep, Antenna, Sample)
            axes[0, idx].set_ylabel('Frame %d ant 0 (Re)' % frame_to_plot)
            axes[0, idx].plot(np.real(samps[frame_to_plot, 0, 0, 0, 1, :]))

            axes[1, idx].set_ylabel('Frame %d ant 1 (Re)' % frame_to_plot)
            axes[1, idx].plot(np.real(samps[frame_to_plot, 0, 0, 0, 1, :]))

            axes[2, idx].set_ylabel('All Frames ant 0 (Re)')
            axes[2, idx].plot(np.real(samps[:, 0, 0, 0, 0, :]).flatten())

            axes[3, idx].set_ylabel('All Frames ant 1 (Re)')
            axes[3, idx].plot(np.real(samps[:, 0, 0, 0, 1, :]).flatten())

            axes[4, idx].set_ylabel('Amplitude')
            for i in range(samps.shape[4]):
                axes[4, idx].plot(np.mean(np.abs(samps[:, 0, 0, 0, i, :]), axis=1).flatten())
            axes[4, idx].set_xlabel('Sample')

            axes[5, idx].set_ylabel('Correlation with Frame %d' % ref_frame)
            axes[5, idx].set_ylim([0, 1.1])
            axes[5, idx].set_title('Cell %d offset %d' % (0, offset))
            for u in range(num_cl_tmp):
                axes[5, idx].plot(corr_total[pilot_frames, u])
            axes[5, idx].set_xlabel('Frame')

        plt.show()


if __name__ == '__main__':
    # Tested with inputs: ./data_in/Argos-2019-3-11-11-45-17_1x8x2.hdf5 300  (for two users)
    #                     ./data_in/Argos-2019-3-30-12-20-50_1x8x1.hdf5 300  (for one user)
    if len(sys.argv) > 1:
        if sys.argv[1] == "-h":
            print('format: ./hdfPlot.py <filename> <frame_to_plot (optional, default=100)>')
            sys.exit(0)

        if len(sys.argv) > 3:
            print('Too many arguments! format: ./hdfPlot.py <filename> <frame_to_plot (optional, default=100)>')
            sys.exit(0)

        filename = sys.argv[1]
        frame_to_plot = []
        if len(sys.argv) == 3:
            frame_to_plot = int(sys.argv[2])

        # Instantiate
        hdf5 = hdfDump(filename)
        hdf5.get_hdf5()
        hdf5.parse_hdf5()

        # Check which data we have available
        data_types_avail = []
        pilots_avail = bool(hdf5.data['Pilot_Samples'])
        ul_data_avail = bool(hdf5.data['UplinkData'])

        if pilots_avail:
            data_types_avail.append("PILOTS")
            print("PILOT Data Available")
        if ul_data_avail:
            data_types_avail.append("UL_DATA")
            print("Uplink Data Available")

        # Empty structure
        if not data_types_avail:
            raise Exception(' **** No pilots or uplink data found **** ')

        hdf5.get_attributes()
        hdf5.get_samples(data_types_avail)

        raw_data = hdf5.data
        metadata = hdf5.metadata
        samples = hdf5.samples

        if frame_to_plot:
            hdf5.verify_hdf5(frame_to_plot)
        else:
            hdf5.verify_hdf5()

    else:
        raise Exception("format: ./hdfPlot.py <filename>")
