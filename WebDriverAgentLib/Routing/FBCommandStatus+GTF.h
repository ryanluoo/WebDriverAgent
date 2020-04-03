//
//  FBCommandStatus+GTF.h
//  WebDriverAgentLib
//
//  Created by ryan on 2020/4/2.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <WebDriverAgentLib/WebDriverAgentLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBCommandStatus (GTF)
+ (instancetype)fileNotExistErrorWithMessage:(nullable NSString *)message
                                   traceback:(nullable NSString *)traceback;

+ (instancetype)incompatibleErrorWithMessage:(nullable NSString *)message
                                   traceback:(nullable NSString *)traceback;

+ (instancetype)unauthorizedErrorWithMessage:(nullable NSString *)message
                                   traceback:(nullable NSString *)traceback;

+ (instancetype)unknownMediaTypeErrorWithMessage:(nullable NSString *)message
                                       traceback:(nullable NSString *)traceback;
@end

NS_ASSUME_NONNULL_END
