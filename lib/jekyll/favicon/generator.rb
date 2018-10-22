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
        @site.static_files.push ico_icon
        @site.static_files.push(*png_icons)
      end

      def ico_icon
        target = Favicon.config['ico']['target']
        Icon.new @site, Favicon.config['source'], target
      end

      def png_icons
        Favicon.config.deep_find('sizes').uniq.collect do |size|
          target = File.join Favicon.config['path'], "favicon-#{size}.png"
          Icon.new @site, Favicon.config['source'], target
        end
      end

      def generate_metadata
        @site.pages.push metadata Resource::Browserconfig.new,
                                  Favicon.config['ie']['browserconfig']
        @site.pages.push metadata Resource::Webmanifest.new,
                                  Favicon.config['chrome']['manifest']
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
