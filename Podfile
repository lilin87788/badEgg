#  * [!] The use of implicit sources has been deprecated. To continue using all of the sources currently on your machine, add the following to the top of your Podfile:
source 'https://github.com/CocoaPods/Specs.git'
##  上面的代码 cocoapods 后面 修改的 具体功能还不定 先按要求添加

platform :ios, '6.0'
# 去掉cocoapods 的所有警告
inhibit_all_warnings!
link_with 'badEgg', 'badEgg Tests'
#  qAlKqlUHY0rGkXQBQKdT8blh 密匙  安全吗 com.cnhnb.telecom
pod 'Baidu-Maps-iOS-SDK', '~> 2.3.0'
# 百度云推送 自带有 jsonkit 和 reachability 所以 我把原来的这2个框架去掉了
pod 'BaiduPushSDK', '~> 1.1.0'
#pod 'FMDB', '~> 2.3'
pod 'FMDB/SQLCipher'
#pod 'JSONKit-NoWarning', '~> 1.2'
pod 'SDWebImage'
pod 'MWPhotoBrowser', '1.4.0'
#pod 'ReactiveCocoa'
pod 'BlocksKit', '~> 2.2.3'
pod 'WebViewJavascriptBridge', '~> 4.1.0'
pod 'RHAddressBook', '~> 1.1.1'
pod 'UI7Kit', :git => 'https://github.com/youknowone/UI7Kit.git'#cocoapods 强制使用最新的代码  这导致的问题是 每次pod update 都会更新代码
#pod 'INTULocationManager'
pod 'MarqueeLabel', '~> 2.0'
#pod 'FCFileManager'
pod 'JazzHands'
pod 'KGModal'
pod 'CWPopup', '~> 1.2.5'
#pod 'KNSemiModalViewController' , '~> 0.4'
pod 'FXBlurView', '~> 1.6.2'
#pod 'WYPopoverController', '~> 0.2.2'
pod 'FXForms', '~> 1.1.6'
pod 'REFrostedViewController', '~> 2.4.6'
pod 'RNFrostedSidebar', '~> 0.2.0'
pod 'HMSegmentedControl', '~> 1.4.0'

pod 'DCKeyValueObjectMapping'
pod 'WEPopover', '~> 1.0.0'
pod 'SVProgressHUD', '~> 1.0'
pod 'JGProgressHUD', '~> 1.2.1'
pod 'MBProgressHUD'
pod 'TTTAttributedLabel', '~> 1.10.1'
pod 'Masonry', '~> 0.5.3'
#pod 'KIImagePager', '~> 1.1.0'
#注意 添加百度地图的框架后会和上面的冲突  解决问题的办法如下 对应的解决网址是（还不知道有什么不可见的问题存在，） bug重现去掉下面的python 代码
#http://www.coderexception.com/CBm31311PWQSQUJX/supported-platforms-base-sdk-build-active-architecture-only-settings-reverted-after-pod-update
post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end