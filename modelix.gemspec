# frozen_string_literal: true

require_relative "lib/modelix/version"

Gem::Specification.new do |spec|
  spec.name          = "modelix"
  spec.version       = Modelix::VERSION
  spec.authors       = ["Brandon Vrooman"]
  spec.email         = ["brandon.vrooman@gmail.com"]

  spec.summary       = "Modelix"
  spec.description   = "Modelix"
  spec.homepage      = "https://www.bvroo.com"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://bvroo.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://bvroo.com"
  spec.metadata["changelog_uri"] = "https://bvroo.com"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "rails"
end
