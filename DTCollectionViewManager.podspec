Pod::Spec.new do |s|
  s.name     = 'DTCollectionViewManager'
  s.version      = "11.0.0"
  s.license  = 'MIT'
  s.summary  = 'Protocol-oriented UICollectionView management, powered by generics and associated types.'
  s.homepage = 'https://github.com/DenTelezhkin/DTCollectionViewManager'
  s.authors  = { 'Denys Telezhkin' => 'denys.telezhkin.oss@gmail.com' }
  s.social_media_url = 'https://twitter.com/DenTelezhkin'
  s.source   = { :git => 'https://github.com/DenTelezhkin/DTCollectionViewManager.git', :tag => s.version.to_s }
  s.source_files = 'Sources/DTCollectionViewManager/*.swift'
  s.swift_versions = ['5.3', '5.4', '5.5']
  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'
  s.frameworks = 'UIKit', 'Foundation'
  s.tvos.framework = 'TVUIKit'
  s.dependency 'DTModelStorage' , '~> 11.0.0'
end
