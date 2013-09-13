base = File.expand_path('..', __FILE__)
cookbook_path File.join(base, 'cookbooks')
json_attribs File.join(base, 'dna.json')
file_cache_path File.join(base, '.chef', 'cache')
log_level :debug
