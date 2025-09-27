module ConfigFiles
  class LoaderFactory
    class << self
      def call(file_name, options = { include_default: true })
        new(options).call(file_name)
      end
    end

    private

    attr_reader :options

    def default_loaders
      {
        Loaders::Yaml => %w[yaml yml],
        Loaders::Json => ['json'],
        Loaders::Conf => ['conf'],
        Loaders::Ini => ['ini'],
        Loaders::Xml => ['xml'],
      }
    end

    def default_loader
      options[:default_loader]
    end

    def default_options
      {
        include_default: true,
        default_loader: Loaders::Yaml,
        loaders: default_loaders,
      }
    end

    def include_default_loaders?
      options[:include_default]
    end

    def loaders
      options[:loaders]
    end

    # Note the check below is necessary, because we only want to do it if it is explicity set
    def initialize(options)
      @options = default_options.merge(options)
      return unless include_default_loaders?

      @options[:loaders] = default_loaders.merge(loaders)
    end

    public

    def call(file_name)
      loaders.detect do |_, extensions|
        extensions.include?(::File.extname(file_name).strip.downcase[1..])
      end&.first || default_loader
    end
  end
end
