Gem::Specification.new do |s|
  s.name        = 'prawn-shadings'
  s.version     = '0.1.1'
  s.date        = Date.today.to_s
  s.summary     = "Advanced PDF shadings for Prawn"
  s.description = "Prawn itself provides only linear and radial gradients. This is the more advanced shadings that PDF spec defines."
  s.authors     = ["Alexander Mankuta"]
  s.email       = 'alex@pointlessone.org'
  s.homepage    = 'http://rubygems.org/gems/prawn-shadings'
  s.license     = 'Ruby-BSD'
  s.licenses    = ['Ruby-BSD', '2-clause BSD']

  s.required_ruby_version = '>= 1.9.3'
  s.required_rubygems_version = '>= 1.3.6'

  s.files       = Dir["{lib,spec}/**/*"] + %w[README.md LICENSE BSDL .rspec Gemfile Rakefile]
  s.require_path = "lib"

  s.extra_rdoc_files = %w{LICENSE BSDL}
  s.rdoc_options << '--title' << 'Prawn Shadings Documentation' <<
                    '--main'  << 'README.md' << '-q'

  s.test_files = Dir["spec/*_spec.rb"]

  s.add_runtime_dependency 'prawn', '>= 1.0.0.rc1', '< 1.1'

  s.add_development_dependency('rdoc')
  s.add_development_dependency('rspec', '~> 2.12')
  s.add_development_dependency('pdf-inspector')
end
