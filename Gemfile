source 'https://rubygems.org'

gem 'prawn', github: 'prawnpdf/prawn'

group :developemnt do
  gem 'rdoc'
end

group :test do
  platforms :rbx do
    gem 'rubysl-securerandom'
    gem 'rubysl-singleton'
    gem 'rubysl-enumerator'
  end

  gem "pdf-inspector", "~> 1.0.2", :require => "pdf/inspector"
  gem "rspec"
  gem "rake"
end
