//
//  BEAudioHelper.m
//  badEgg
//
//  Created by lilin on 13-12-11.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEAudioHelper.h"

@implementation BEAudioHelper
+ (BOOL)hasMicphone {
    return [[AVAudioSession sharedInstance] inputIsAvailable];
}

//是不是有耳机
/* Known values of route:
 * "Headset"
 * "Headphone"
 * "Speaker"
 * "SpeakerAndMicrophone"
 * "HeadphonesAndMicrophone"
 * "HeadsetInOut"
 * "ReceiverAndMicrophone"
 * "Lineout"
 */
- (BOOL)hasHeadset {
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize,&route);
    
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (__bridge NSString*)route;
        NSLog(@"AudioRoute: %@", routeStr);
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
#endif
}
//获取 当前audiosession 的工作模式
+(void)printCurrentCategory
{
    UInt32 audioCategory;
    UInt32 size = sizeof(audioCategory);
    AudioSessionGetProperty(kAudioSessionProperty_AudioCategory, &size, &audioCategory);
    if ( audioCategory == kAudioSessionCategory_UserInterfaceSoundEffects ){
        NSLog(@"current category is : dioSessionCategory_UserInterfaceSoundEffects");
    } else if ( audioCategory == kAudioSessionCategory_AmbientSound ){
        NSLog(@"current category is : kAudioSessionCategory_AmbientSound");
    } else if ( audioCategory == kAudioSessionCategory_AmbientSound ){
        NSLog(@"current category is : kAudioSessionCategory_AmbientSound");
    } else if ( audioCategory == kAudioSessionCategory_SoloAmbientSound ){
        NSLog(@"current category is : kAudioSessionCategory_SoloAmbientSound");
    } else if ( audioCategory == kAudioSessionCategory_MediaPlayback ){
        NSLog(@"current category is : kAudioSessionCategory_MediaPlayback");
    } else if ( audioCategory == kAudioSessionCategory_LiveAudio ){
        NSLog(@"current category is : kAudioSessionCategory_LiveAudio");
    } else if ( audioCategory == kAudioSessionCategory_RecordAudio ){
        NSLog(@"current category is : kAudioSessionCategory_RecordAudio");
    } else if ( audioCategory == kAudioSessionCategory_PlayAndRecord ){
        NSLog(@"current category is : kAudioSessionCategory_PlayAndRecord");
    } else if ( audioCategory == kAudioSessionCategory_AudioProcessing ){
        NSLog(@"current category is : kAudioSessionCategory_AudioProcessing");
    } else {
        NSLog(@"current category is : unknow");
    }
}
@end
