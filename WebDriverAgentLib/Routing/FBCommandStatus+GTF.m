//
//  FBCommandStatus+GTF.m
//  WebDriverAgentLib
//
//  Created by ryan on 2020/4/2.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "FBCommandStatus+GTF.h"

@implementation FBCommandStatus (GTF)

static NSString *const GTF_FILE_NOT_EXIST_ERROR = @"file not exist";
static const HTTPStatusCode GTF_FILE_NOT_EXIST_ERROR_CODE = kHTTPStatusCodeNotFound;
static NSString *const GTF_FILE_NOT_EXIST_MSG = @"File was never generated or saved in the path";

+ (instancetype)fileNotExistErrorWithMessage:(NSString *)message
                                   traceback:(NSString *)traceback
{
  return [[FBCommandStatus alloc] initWithError:GTF_FILE_NOT_EXIST_ERROR
                                     statusCode:GTF_FILE_NOT_EXIST_ERROR_CODE
                                        message:message ?: GTF_FILE_NOT_EXIST_MSG
                                      traceback:traceback];
}

static NSString *const GTF_INCOMPATIBLE_ERROR = @"incompatible";
static const HTTPStatusCode GTF_INCOMPATIBLE_ERROR_CODE = kHTTPStatusCodeMethodNotAllowed;
static NSString *const GTF_INCOMPATIBLE_MSG = @"An operation was not supported on current device";

+ (instancetype)incompatibleErrorWithMessage:(NSString *)message
                                   traceback:(NSString *)traceback
{
  return [[FBCommandStatus alloc] initWithError:GTF_INCOMPATIBLE_ERROR
                                     statusCode:GTF_INCOMPATIBLE_ERROR_CODE
                                        message:message ?: GTF_INCOMPATIBLE_MSG
                                      traceback:traceback];
}


static NSString *const GTF_UNAUTHORIZED_ERROR = @"unauthorized";
static const HTTPStatusCode GTF_UNAUTHORIZED_ERROR_CODE = kHTTPStatusCodeUnauthorized;
static NSString *const GTF_UNAUTHORIZED_MSG = @"An operation was not permitted";

+ (instancetype)unauthorizedErrorWithMessage:(NSString *)message
                                   traceback:(NSString *)traceback
{
  return [[FBCommandStatus alloc] initWithError:GTF_UNAUTHORIZED_ERROR
                                     statusCode:GTF_UNAUTHORIZED_ERROR_CODE
                                        message:message ?: GTF_UNAUTHORIZED_MSG
                                      traceback:traceback];
}

static NSString *const GTF_UNKNOWN_MEDIA_TYPE_ERROR = @"unknown media type";
static const HTTPStatusCode GTF_UNKNOWN_MEDIA_TYPE_ERROR_CODE = kHTTPStatusCodeUnsupportedMediaType;
static NSString *const GTF_UNKNOWN_MEDIA_TYPE_MSG = @"An unsupported media type was set. Only mp4, mov, png, jpg was supported.";

+ (instancetype)unknownMediaTypeErrorWithMessage:(NSString *)message
                                       traceback:(NSString *)traceback
{
  return [[FBCommandStatus alloc] initWithError:GTF_UNKNOWN_MEDIA_TYPE_ERROR
                                     statusCode:GTF_UNKNOWN_MEDIA_TYPE_ERROR_CODE
                                        message:message ?: GTF_UNKNOWN_MEDIA_TYPE_MSG
                                      traceback:traceback];
}

@end
