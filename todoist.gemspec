# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'todoist/version'

Gem::Specification.new do |spec|
  spec.name          = "todoist"
  spec.version       = Todoist::VERSION
  spec.authors       = ["Han Yuan"]
  spec.email         = ["han.yuan@gmail.com"]

  spec.summary       = %q{This gem provides access to the latest Todoist API.}
  spec.description   = %q{This gem provides access to the latest Todoist API.  It is designed to be as lightweight as possible.  While the gem provides interfaces for the sync API calls, no support is provided for persisting the result of these calls.  Collaboration API calls are not supported at this time.}
  spec.homepage      = "https://github.com/h6y3/todoist-ruby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "simplecov"
  spec.add_dependency "concurrent-ruby"
  spec.add_dependency "multipart-post"
  spec.add_dependency "mimemagic"
  
end
