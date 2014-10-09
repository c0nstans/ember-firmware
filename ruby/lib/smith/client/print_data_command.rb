# Class to handle print_data command
# Downloads file specified in command payload and sends commands necessary to
# apply settings and process print data

require 'em-http'

module Smith
  module Client
    class PrintDataCommand

      def initialize(printer, payload)
        @printer = printer
        @file_url, @settings = payload.values_at(:file_url, :settings)
      end

      def handle
        # Only start a download if the printer is in the home state
        @printer.validate_state { |state, substate| state == HOME_STATE }
      rescue Printer::InvalidState => e
        Client.log_error("#{e.message}, not downloading print data, aborting print_data command handling")
      else
        # This runs if no exceptions were raised
        EM.next_tick do

          # Purge the print data dir
          # smith expects this directory to contain a single file when it receives the process print data command
          # There may be a file left over as a result of an error
          @printer.purge_print_data_dir

          # Open a new file for writing in the print data directory with
          # the same name as the last component in the file url
          @file = File.open(File.join(Smith.print_data_dir, @file_url.split('/').last), 'wb')
          download_request = EM::HttpRequest.new(@file_url).get

          download_request.errback { download_failed }
          download_request.callback { download_completed }
          download_request.stream { |chunk| chunk_available(chunk) }

        end
      end

      private

      def download_completed
        Client.log_info("Print data download of #{@file_url} complete, file downloaded to #{@file.path}")
        @file.close

        # Validate printer state and command printer to show loading screen
        @printer.validate_state { |state, substate| state == HOME_STATE && substate != DOWNLOAD_FAILED_SUBSTATE }
        @printer.send_command(CMD_PRINT_DATA_LOAD)

        # Make sure printer is ready to process print data
        @printer.validate_state { |state, substate| state == HOME_STATE && substate != DOWNLOAD_FAILED_SUBSTATE }
        
        # Save print settings to temp file
        File.write(Client.print_settings_file, @settings)
       
        # Command printer to process print data 
        @printer.send_command(CMD_PROCESS_PRINT_DATA)
       
        # Send command to load print settings from print settings file 
        @printer.send_command(CMD_APPLY_PRINT_SETTINGS)
      rescue Printer::InvalidState => e
        Client.log_error("#{e.message}, aborting print_data command handling")
      end

      def download_failed
        Client.log_error("Error downloading print data from #{@file_url}")
        @file.close
      end

      def chunk_available(chunk)
        @file.write(chunk)
      end

    end
  end
end
