module Jekyll
  module Favicon
    module Resource
      # Creates graphic assets
      module Graphic
        class UnsupportedCopy < StandardError; end
        class UnsupportedSourceFormat < StandardError; end
        class UnsupportedTargetFormat < StandardError; end

        def self.copy(source, target, icon_config = {})
          if target.svg?
            raise UnsupportedCopy unless source.svg?
            return FileUtils.cp source, target if source.svg?
          end
          options = {}
          options.merge! source_options icon_config
          options.merge! target_options icon_config
          convert source, target, options
        end

        def self.source_options(icon_config)
          case File.extname icon_config['source']
          when '.svg' then icon_config['svg'] || {}
          when '.png' then icon_config['png'] || {}
          else raise UnsupportedSourceFormat
          end
        end

        def self.target_options(icon_config)
          case File.extname icon_config['target']
          when '.svg' then {}
          when '.ico' then ico_options icon_config
          when '.png' then png_options icon_config
          else raise UnsupportedTargetFormat
          end
        end

        def self.ico_options(config)
          options = {}
          options[:background] = config['background']
          options[:alpha] = config['alpha']
          options[:resize] = config['sizes'].first
          ico_sizes = config['sizes'].collect do |size|
            size.split('x').first
          end.join ','
          options[:define] = "icon:auto-resize=#{ico_sizes}"
          options
        end

        def self.png_options(config)
          options = {}
          options[:background] = config['background']
          w, h = config['size'].split('x').collect(&:to_i)
          options[:odd] = w != h
          options[:resize] = config['size']
          options
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
          convert.density options['density'] if options['density']
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
