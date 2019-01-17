module Jekyll
  module Favicon
    # Extended static file that generates multpiple favicons
    class Icon < Jekyll::StaticFile
      attr_accessor :icon

      def initialize(site, icon, collection = nil)
        @site = site
        @base = @site.source
        @dir  = File.dirname icon['source']
        @name = File.basename icon['source']
        @collection = collection
        @relative_path = File.join(*[@dir, @name].compact)
        @extname = File.extname @name
        @data = { 'name' => @name, 'layout' => nil }
        @icon = icon
      end

      def destination(dest = '')
        target_path = File.join(@icon['path'], @icon['target'])
        @site.in_dest_dir(*[dest, target_path].compact)
      end

      def modified?(dest)
        source_modified?(dest_path) || target_is_older_than_source?(dest_path)
      end

      def write(dest)
        dest_path = destination dest
        return false if File.exist?(dest_path) && !modified?(dest_path)
        self.class.mtimes[[path, destination]] = mtime
        FileUtils.mkdir_p File.dirname dest_path
        FileUtils.rm dest_path if File.exist? dest_path
        copy_file dest_path
        true
      end

      private

      def copy_file(dest_path)
        Resource::Graphic.copy path, dest_path, @icon
        icon_mtime = self.class.mtimes[[path, destination]]
        File.utime icon_mtime, icon_mtime, dest_path
      rescue Resource::Graphic::UnsupportedSourceFormat,
             Resource::Graphic::UnsupportedTargetFormat
        Jekyll.logger.warn "Jekyll::Favicon Can't create #{dest_path}: " \
                           'target format not supported supported.'
      end

      def source_modified?(dest_path)
        self.class.mtimes[[path, dest_path]] != mtime
      end

      def target_is_older_than_source(dest_path)
        File.stat(dest_path).mtime.to_i < mtime
      end
    end
  end
end
