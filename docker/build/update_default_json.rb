require 'rubygems'
require 'rbconfig'
require 'fileutils'

gem_directory = File.join(ENV.fetch('BUNDLE_PATH'), 'ruby', RbConfig::CONFIG.fetch('ruby_version'))
specifications = Dir[File.join(gem_directory, 'specifications', 'json-*.gemspec')]
spec = specifications.map { |path| Gem::Specification.load(path) }.max_by(&:version)
raise 'A patched bundled JSON gem is required' unless spec && spec.version >= Gem::Version.new('2.19.9')

source = File.join(spec.full_gem_path, 'lib')
ruby_library = RbConfig::CONFIG.fetch('rubylibdir')
native_library = RbConfig::CONFIG.fetch('archdir')
extension = RbConfig::CONFIG.fetch('DLEXT')
native_files = Dir[File.join(source, 'json', '**', "*.#{extension}")]
required_extensions = %w[generator parser].map { |name| "/#{name}.#{extension}" }
unless required_extensions.all? { |name| native_files.any? { |path| path.end_with?(name) } }
  raise 'Compiled JSON extensions are missing'
end

FileUtils.rm_f(File.join(ruby_library, 'json.rb'))
FileUtils.rm_rf(File.join(ruby_library, 'json'))
FileUtils.rm_rf(File.join(native_library, 'json'))
FileUtils.cp(File.join(source, 'json.rb'), ruby_library)
FileUtils.cp_r(File.join(source, 'json'), ruby_library)
native_files.each do |path|
  relative = path.delete_prefix("#{source}/")
  destination = File.join(native_library, relative)
  FileUtils.mkdir_p(File.dirname(destination))
  FileUtils.cp(path, destination)
  FileUtils.rm_f(File.join(ruby_library, relative))
end

spec.files = Dir[File.join(source, '**', '*')].select { |path| File.file?(path) }.map { |path| path.delete_prefix("#{source}/") }
spec.require_paths = ['lib']
spec.extensions = []
FileUtils.rm_f(Dir[File.join(Gem.default_specifications_dir, 'json-*.gemspec')])
Gem.write_binary(File.join(Gem.default_specifications_dir, "#{spec.full_name}.gemspec"), spec.to_ruby)
puts "Replaced the default JSON implementation with #{spec.version}"
