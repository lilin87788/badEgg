//
//  BEPlayerController.h
//  badEgg
//
//  Created by lilin on 13-11-28.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEAlbumItem.h"
#import "AudioButton.h"
#import "HysteriaPlayer.h"
@interface BEPlayerController : BEViewController<HysteriaPlayerDelegate>
{
    
}

@property(nonatomic,strong)BEAlbumItem* currentItems;
@property(nonatomic)NSUInteger currentIndex;
@property BOOL isClickPlaingBtn;
@end
