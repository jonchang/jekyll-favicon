module Jekyll
  module Favicon
    module Resource
      # Creates graphic assets
      module Graphic
        class UnsupportedFormat < StandardError; end
        class UnsupportedCopy < StandardError; end

        def self.copy(source, target, options = {})
          if target.svg?
            raise UnsupportedCopy unless source.svg?
            return FileUtils.cp source, target if source.svg?
          end
          options.merge! source_options source
          options.merge! target_options target
          convert source, target, options
        end

        def self.source_options(path)
          case File.extname path
          when '.svg' then Jekyll::Favicon.config['svg']
          when '.png' then Jekyll::Favicon.config['png']
          else raise UnsupportedFormat
          end
        end

        def self.target_options(path)
          case File.extname path
          when '.svg' then {}
          when '.ico' then ico_options Jekyll::Favicon.config['ico']
          when '.png' then png_options(path)
          else raise UnsupportedFormat
          end
        end

        def self.ico_options(config)
          options = {}
          sizes = config['sizes']
          options[:background] = background_for sizes.first
          options[:alpha] = 'off'
          options[:resize] = sizes.first
          ico_sizes = sizes.collect { |size| size.split('x').first }.join ','
          options[:define] = "icon:auto-resize=#{ico_sizes}"
          options
        end

        def self.png_options(path)
          options = {}
          basename = File.basename path
          w, h = basename[/favicon-(\d+x\d+).png/, 1].split('x').collect(&:to_i)
          size = "#{w}x#{h}"
          options[:background] = background_for size
          options[:odd] = w != h
          options[:resize] = size
          options
        end

        def self.background_for(size)
          category = Jekyll::Favicon.config['apple-touch-icon']
          return category['background'] if category['sizes'].include? size
          Jekyll::Favicon.config['background']
        end

        def self.convert(source, output, options = {})
          MiniMagick::Tool::Convert.new do |convert|
            options_for convert, options
            convert << source
            convert << output
          end
        end

        def self.options_for(convert, options)
          convert.flatten
          basic_options convert, options
          resize_options convert, options
          odd_options convert, options
        end

        def self.basic_options(convert, options)
          convert.background options[:background] if options[:background]
          convert.define options[:define] if options[:define]
          convert.density options[:density] if options[:density]
          convert.alpha options[:alpha] if options[:alpha]
        end

        def self.resize_options(convert, options)
          convert.resize options[:resize] if options[:resize]
        end

        def self.odd_options(convert, options)
          convert.gravity 'center' if options[:odd]
          convert.extent options[:resize] if options[:odd] && options[:resize]
        end
      end
    end
  end
end
