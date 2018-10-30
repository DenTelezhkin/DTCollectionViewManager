Pod::Spec.new do |s|
  s.name     = 'DTCollectionViewManager'
  s.version      = "6.4.1"
  s.license  = 'MIT'
  s.summary  = 'Protocol-oriented UICollectionView management, powered by generics and associated types.'
  s.homepage = 'https://github.com/DenHeadless/DTCollectionViewManager'
  s.authors  = { 'Denys Telezhkin' => 'denys.telezhkin.oss@gmail.com' }
  s.social_media_url = 'https://twitter.com/DenTelezhkin'
  s.source   = { :git => 'https://github.com/DenHeadless/DTCollectionViewManager.git', :tag => s.version.to_s }
  s.source_files = 'Source/*.swift'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'DTModelStorage' , '~> 7.2.0'
end
