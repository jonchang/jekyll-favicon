require 'yaml'

module Jekyll
  # Module for custom configurations and defaults
  module Favicon
    GEM_ROOT = File.dirname File.dirname __dir__
    PROJECT_LIB = File.join GEM_ROOT, 'lib'
    PROJECT_ROOT = File.join PROJECT_LIB, 'jekyll', 'favicon'
    defaults_path = File.join PROJECT_ROOT, 'config', 'defaults.yml'
    DEFAULTS = YAML.load_file(defaults_path)['favicon']

    # rubocop:disable  Style/ClassVars
    def self.merge(overrides)
      @@config = Utils.deep_merge_hashes DEFAULTS, (overrides || {})
    end

    def self.config
      @@config ||= DEFAULTS
    end

    def self.reset
      @@config = DEFAULTS
      @@targets = nil
    end

    def self.targets
      @@targets ||= config['icons'].collect do |group, attributes|
        shared_config = Utils.deep_merge_hashes global_config,
                                                group_config(attributes)
        attributes['targets'].collect do |target|
          Utils.deep_merge_hashes shared_config,
                                  target_config(target, 'group' => group)
        end
      end.flatten
    end
    # rubocop:enable  Style/ClassVars

    def self.templates
      File.join PROJECT_ROOT, 'templates'
    end

    def self.exclude
      files = []
      files << config['source']
      files << config['webmanifest']['source']
      files << config['browserconfig']['source']
      files
    end

    def self.global_config
      config.reject do |attribute, _|
        %w[icons webmanifest browserconfig].include? attribute
      end
    end

    def self.group_config(attributes)
      attributes.reject do |attribute, _|
        attribute == 'targets'
      end
    end

    def self.target_config(target, extra = {})
      case target
      when Hash then target
      when String then {
        'target' => target,
        'size' => target[/favicon-(\d+x\d+).png/, 1]
      }
      end.merge extra
    end
  end
end
