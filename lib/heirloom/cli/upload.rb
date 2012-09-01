module Heirloom
  module CLI
    class Upload

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts, 
                             :required => [:name, :id, :directory],
                             :config   => @config
        @catalog = Catalog.new :name    => @opts[:name],
                               :config  => @config
        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :config => @config
        @regions = @catalog.regions
        @base    = @catalog.base
      end

      def upload
        ensure_valid_region :region => @opts[:metadata_region],
                            :config => @config
        ensure_domain_exists :name   => @opts[:name], 
                             :config => @config
        ensure_buckets_exist :base    => @base,
                             :name    => @opts[:name],
                             :regions => @regions,
                             :config  => @config
        ensure_directory :path   => @opts[:directory], 
                         :config => @config
        ensure_valid_secret :secret => @opts[:secret], 
                            :config => @config

        @archive.destroy if @archive.exists?
                          
        build = @archive.build :base       => @base,
                               :directory  => @opts[:directory],
                               :exclude    => @opts[:exclude],
                               :git        => @opts[:git],
                               :secret     => @opts[:secret]

        unless build
          @logger.error "Build failed."
          exit 1
        end

        @archive.upload :bucket_prefix   => @base,
                        :regions         => @regions,
                        :public_readable => @opts[:public],
                        :file            => build
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Upload a directory to Heirloom.

Usage:

heirloom upload -n NAME -i ID -d DIRECTORY_TO_UPLOAD

EOS
          opt :directory, "Source directory of build.", :type  => :string
          opt :exclude, "File(s) or directorie(s) to exclude. \
Can be specified multiple times.", :type  => :string, :multi => true
          opt :git, "Read git commit information from directory and set as archive attributes."
          opt :help, "Display Help"
          opt :id, "ID for archive (when -g specified, assumed to be GIT sha).", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string,   
                                                                          :default => 'us-west-1'
          opt :name, "Name of archive.", :type => :string
          opt :public, "Set this archive as public readable?"
          opt :secret, "Encrypt the archive with given secret.", :type => :string
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
        end
      end

    end
  end
end
