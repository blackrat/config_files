module ConfigFiles
  class LoaderFactory
    class << self
      public
      def call(file_name, options={include_default: true})
        new(options).call(file_name)
      end
    end

    private
    attr_reader :options

    def default_loaders
      {
        Loaders::Yaml => ['yaml', 'yml'],
        Loaders::Json =>  ['json']
      }
    end

    def default_loader
      options[:default_loader]
    end

    def default_options
      {
        include_default: true,
        default_loader: Loaders::Yaml,
        loaders: default_loaders
      }
    end

    def include_default_loaders?
      options[:include_default]
    end

    def loaders
      options[:loaders]
    end

    def initialize(options) #Note the check below is necessary, because we only want to do it if it is explicity set
      @options=default_options.merge(options)
      if include_default_loaders?
        @options[:loaders]=default_loaders.merge(loaders)
      end
    end

    public
    def call(file_name)
      loaders.detect{|_, extensions| extensions.include?(::File.extname(file_name).strip.downcase[1..-1])}&.first || default_loader
    end
  end
end
