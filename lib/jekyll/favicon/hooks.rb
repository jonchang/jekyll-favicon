Jekyll::Hooks.register :site, :after_init do |site|
  Jekyll::Favicon.reset
  Jekyll::Favicon.merge site.config['favicon']
  site.config['exclude'].push(*Jekyll::Favicon.exclude)
end
