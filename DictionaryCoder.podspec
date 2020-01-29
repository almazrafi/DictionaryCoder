Pod::Spec.new do |spec|
  spec.name = "DictionaryCoder"
  spec.version = "1.0.0"
  spec.summary = "Swift Encoder and Decoder for dictionaries"

  spec.homepage = "https://github.com/almazrafi/DictionaryCoder"
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { "Almaz Ibragimov" => "almazrafi@gmail.com" }
  spec.source = { :git => "https://github.com/almazrafi/DictionaryCoder.git", :tag => "#{spec.version}" }

  spec.swift_version = '5.0'
  spec.requires_arc = true
  spec.source_files = 'Sources/**/*.swift'

  spec.ios.frameworks = 'Foundation'
  spec.ios.deployment_target = "10.0"

  spec.osx.frameworks = 'Foundation'
  spec.osx.deployment_target = "10.12"

  spec.watchos.frameworks = 'Foundation'
  spec.watchos.deployment_target = "3.0"

  spec.tvos.frameworks = 'Foundation'
  spec.tvos.deployment_target = "10.0"
end
