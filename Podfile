project 'ShelfCentered/ShelfCentered.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'SCCore' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'IGListKit', '~> 3.0'
  pod 'RealmSwift'
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'RxRealm'
  pod 'RxOptional'
  pod 'IceCream'

  target 'SCCoreTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'ShelfCentered' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ShelfCentered

  target 'ShelfCenteredTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ShelfCenteredUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
