module ConfigFiles
  class FileFactory
    class << self
      private

      def loader(file_name, options)
        LoaderFactory.call(file_name, options)
      end

      public

      def call(file_name, options = {})
        loader(file_name, options).call(file_name)
      end
    end
  end
end
