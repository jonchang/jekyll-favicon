module Jekyll
  module Favicon
    # Extended generator that creates all the stastic icons and metadata files
    class Generator < Jekyll::Generator
      priority :high

      def generate(site)
        @site = site
        if File.file? source_path Favicon.config['source']
          generate_icons && generate_metadata
        else
          Jekyll.logger.warn 'Jekyll::Favicon: Missing ' \
                             "#{Favicon.config['source']}, not generating " \
                             'favicons.'
        end
      end

      private

      def source_path(path = nil)
        File.join(*[@site.source, path].compact)
      end

      def generate_icons
        Favicon.targets.each do |icon|
          @site.static_files.push Icon.new @site, icon
        end
      end

      def generate_metadata
        @site.pages.push metadata Resource::Browserconfig.new,
                                  Favicon.config['browserconfig']
        @site.pages.push metadata Resource::Webmanifest.new,
                                  Favicon.config['webmanifest']
      end

      def metadata(document, config)
        page = Metadata.new @site, @site.source,
                            File.dirname(config['target']),
                            File.basename(config['target'])
        favicon_path = File.join (@site.baseurl || ''), Favicon.config['path']
        document.load source_path(config['source']), config, favicon_path
        page.content = document.dump
        page.data = { 'layout' => nil }
        page
      end
    end
  end
end
