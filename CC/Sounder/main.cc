/*
 Copyright (c) 2018-2022, Rice University 
 RENEW OPEN SOURCE LICENSE: http://renew-wireless.org/license
 
---------------------------------------------------------------------
 main function
 - initializes all Clients
 - Brings up Recorder and the BaseStation
---------------------------------------------------------------------
*/

#include <gflags/gflags.h>

#include <iostream>

#include "include/data_generator.h"
#include "include/scheduler.h"
#include "include/signalHandler.hpp"
#include "include/version_config.h"

DEFINE_bool(
    gen_data_bits, false,
    "Generate random bits for uplink/downlink transmissions, otherwise read "
    "from file!");
DEFINE_string(conf_file, "files/conf.json", "JSON configuration file name");
DEFINE_string(storepath, "logs", "Dataset store path");
DEFINE_bool(bs_only, false, "Run BS only");
DEFINE_bool(client_only, false, "Run client only");
DEFINE_bool(calibrate, false, "Run radio set calibration");

int main(int argc, char* argv[]) {
  gflags::SetVersionString(GetSounderProjectVersion());
  gflags::SetUsageMessage(
      "sounder Options: -bs_only -client_only -conf "
      "-gen_data_bits -storepath");
  gflags::ParseCommandLineFlags(&argc, &argv, true);
  auto config =
      std::make_unique<Config>(FLAGS_conf_file, FLAGS_storepath, FLAGS_bs_only,
                               FLAGS_client_only, FLAGS_calibrate);
  int ret = EXIT_FAILURE;
  if (FLAGS_gen_data_bits) {
    auto dg = std::make_unique<DataGenerator>(config.get());
    dg->GenerateData(FLAGS_storepath);
  } else if (FLAGS_calibrate) {
    auto base_radio_set_ = std::make_unique<BaseRadioSet>(config.get(), true);
  } else {
    int cnt = 0;
    int maxTry = 2;

    // Register signal handler to handle kill signal
    SignalHandler signalHandler;
    signalHandler.setupSignalHandlers();

    while (cnt++ < maxTry && ret == EXIT_FAILURE) {
      try {
        auto dr = std::make_unique<Sounder::Scheduler>(config.get());
        dr->do_it();
        ret = EXIT_SUCCESS;

      } catch (const SignalException& e) {
        std::cerr << "SignalException: " << e.what() << std::endl;
        ret = EXIT_FAILURE;
        break;

      } catch (ReceiverException& rex) {
        // Discovery usually fails on the first run, re-try
        std::cout << "Exception: " << rex.what() << " Re-Try Now!" << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(1));

      } catch (const std::exception& exc) {
        std::cerr << "Exception Encountered... Program terminated due to "
                  << exc.what() << std::endl;
        ret = EXIT_FAILURE;
        break;
      }
    }
  }
  gflags::ShutDownCommandLineFlags();
  return ret;
}
