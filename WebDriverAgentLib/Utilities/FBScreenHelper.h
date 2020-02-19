//
//  FBScreenHelper.h
//  WebDriverAgentLib
//
//  Created by cheney on 2019/4/10.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBScreenHelper : NSObject

+ (CGSize)screenSize;

+ (CGRect)screenRect;

@end

NS_ASSUME_NONNULL_END
