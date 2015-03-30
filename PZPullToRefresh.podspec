Pod::Spec.new do |s|
  s.name = "PZPullToRefresh"
  s.version = "0.0.4"
  s.summary = "This is the simplest refresh control in Swift."
  s.homepage = 'https://github.com/pixyzehn/PZPullToRefresh'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { "pixyzehn" => "civokjots0109@gmail.com" }

  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.source = { :git => "https://github.com/pixyzehn/PZPullToRefresh.git", :tag => "#{s.version}" }
  s.source_files = "PZPullToRefresh/*.swift"
end
