module Heirloom
  module CLI
    class Download

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:base_prefix, :name, :id, :output],
                             :config   => @config


        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :config => @config
      end
      
      def download
        ensure_directory :path => @opts[:output], :config => @config
        @archive.download :output      => @opts[:output],
                          :region      => @opts[:region],
                          :extract     => @opts[:extract],
                          :base_prefix => @opts[:base_prefix]
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Download an archive.

Usage:

heirloom download -n NAME -i ID -r REGION -o OUTPUT_FILE

EOS
          opt :help, "Display Help"
          opt :base_prefix, "Base prefix of the archive to download.", :type => :string
          opt :id, "ID of the archive to download.", :type => :string
          opt :key, "AWS Access Key ID", :type => :string
          opt :name, "Name of archive.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :output, "Path to download archive.", :type => :string
          opt :extract, "Extract the archive in the given output path.", :short => "-x"
          opt :region, "Region to download archive.", :type    => :string,
                                                      :default => 'us-west-1'
          opt :secret, "AWS Secret Access Key", :type => :string
        end
      end
    end
  end
end
