module Jekyll
  module Favicon
    # Extended static file that generates multpiple favicons
    class Icon < Jekyll::StaticFile
      attr_accessor :target

      def initialize(site, source, target, collection = nil)
        @site = site
        @base = @site.source
        @dir  = File.dirname source
        @name = File.basename source
        @collection = collection
        @relative_path = File.join(*[@dir, @name].compact)
        @extname = File.extname @name
        @data = { 'name' => @name, 'layout' => nil }
        @target = target
      end

      def destination(dest)
        @site.in_dest_dir(*[dest, @target].compact)
      end

      def modified?(dest_path)
        mtimes = self.class.mtimes
        mtimes[[path, @target]] ||= mtime
        source_has_been_modified = mtimes[[path, @target]] != mtime
        target_is_older_than_source = File.stat(dest_path).mtime.to_i < mtime
        source_has_been_modified || target_is_older_than_source
      end

      def write(dest)
        dest_path = destination dest
        return false if File.exist?(dest_path) && !modified?(dest_path)
        self.class.mtimes[[path, @target]] = mtime
        FileUtils.mkdir_p File.dirname dest_path
        FileUtils.rm dest_path if File.exist? dest_path
        copy_file dest_path
        true
      end

      private

      def copy_file(dest_path)
        Resource::Graphic.copy path, dest_path
        icon_mtime = self.class.mtimes[[path, @target]]
        File.utime icon_mtime, icon_mtime, dest_path
      rescue Graphic::UnsupportedCopy
        Jekyll.logger.debug "Jekyll::Favicon Can't create #{target}: " \
                           "copy from #{path} not supported supported."
      rescue Graphic::UnsupportedSourceFormat, Graphic::UnsupportedTargetFormat
        Jekyll.logger.warn "Jekyll::Favicon Can't create #{target}: " \
                           'extension not supported supported.'
      end
    end
  end
end
