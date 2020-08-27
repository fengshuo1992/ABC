Pod::Spec.new do |s|
  s.name = "ABC"
  s.version = "34"
  s.summary = "A short description of ABC."
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"fengshuo1992"=>"963787902@qq.com"}
  s.homepage = "https://github.com/fengshuo1992/ABC"
  s.description = "TODO: Add long description of the pod here."
  s.source = { :path => '.' }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/ABC.framework'
end
