#  * [!] The use of implicit sources has been deprecated. To continue using all of the sources currently on your machine, add the following to the top of your Podfile:
source 'https://github.com/CocoaPods/Specs.git'
##  上面的代码 cocoapods 后面 修改的 具体功能还不定 先按要求添加

platform :ios,'7.1'
# 去掉cocoapods 的所有警告
inhibit_all_warnings!
link_with 'badEgg', 'badEgg Tests'
pod 'AFNetworking', '~> 2.5.0'

pod 'Baidu-Maps-iOS-SDK', '~> 2.3.0'
#pod 'SDWebImage', '~> 3.7.1'
#pod 'MWPhotoBrowser', '1.4.1'
pod 'FMDB/SQLCipher'
pod 'JSONKit-NoWarning', '~> 1.2'

pod 'BlocksKit', '~> 2.2.3'
#pod 'UI7Kit', '~> 0.9.20'
pod 'MarqueeLabel', '~> 2.0'
#pod 'FCFileManager'
#pod 'CWPopup', :git =>'https://github.com/cezarywojcik/CWPopup.git'
#pod 'KNSemiModalViewController' , '~> 0.4'
pod 'FXBlurView', '~> 1.6.2'
pod 'FXForms', '~> 1.1.6'
pod 'HMSegmentedControl', '~> 1.4.0'

pod 'DCKeyValueObjectMapping'
pod 'SVProgressHUD', '~> 1.0'
pod 'JGProgressHUD', '~> 1.2.1'
pod 'MBProgressHUD'
pod 'TTTAttributedLabel', '~> 1.10.1'
pod 'Masonry', '~> 0.5.3'

post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end