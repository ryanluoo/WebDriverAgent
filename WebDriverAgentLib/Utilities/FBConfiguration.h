/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import "AXSettings.h"
#import "UIKeyboardImpl.h"
#import "TIPreferencesController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Accessors for Global Constants.
 */
@interface FBConfiguration : NSObject

/*! If set to YES will ask TestManagerDaemon for element visibility */
+ (void)setShouldUseTestManagerForVisibilityDetection:(BOOL)value;
+ (BOOL)shouldUseTestManagerForVisibilityDetection;

/*! If set to YES will use compact (standards-compliant) & faster responses */
+ (void)setShouldUseCompactResponses:(BOOL)value;
+ (BOOL)shouldUseCompactResponses;

/*! If shouldUseCompactResponses == NO, is the comma-separated list of fields to return with each element. Defaults to "type,label". */
+ (void)setElementResponseAttributes:(NSString *)value;
+ (NSString *)elementResponseAttributes;

/*! Disables remote query evaluation making Xcode 9.x tests behave same as Xcode 8.x test */
+ (void)disableRemoteQueryEvaluation;

/*! Disables attribute key path analysis, which will cause XCTest on Xcode 9.x to ignore some elements */
+ (void)disableAttributeKeyPathAnalysis;

/* The maximum typing frequency for all typing activities */
+ (void)setMaxTypingFrequency:(NSUInteger)value;
+ (NSUInteger)maxTypingFrequency;

/* Use singleton test manager proxy */
+ (void)setShouldUseSingletonTestManager:(BOOL)value;
+ (BOOL)shouldUseSingletonTestManager;

/* Whether to wait for quiescence on application startup */
+ (void)setShouldWaitForQuiescence:(BOOL)value;
+ (BOOL)shouldWaitForQuiescence;

/**
 * Extract switch value from arguments
 *
 * @param arguments Array of strings with the command-line arguments, e.g. @[@"--port", @"12345"].
 * @param key Switch to look up value for, e.g. @"--port".
 *
 * @return Switch value or nil if the switch is not present in arguments.
 */
+ (NSString* _Nullable)valueFromArguments: (NSArray<NSString *> *)arguments forKey: (NSString*)key;

/**
 The quality of the screenshots generated by the screenshots broadcaster, expressed
 as a value from 0 to 100. The value 0 represents the maximum compression
 (or lowest quality) while the value 100 represents the least compression (or best
 quality). The default value is 25.
 */
+ (NSUInteger)mjpegServerScreenshotQuality;
+ (void)setMjpegServerScreenshotQuality:(NSUInteger)quality;

/**
 The framerate at which the background screenshots broadcaster should broadcast
 screenshots in range 1..60. The default value is 10 (Frames Per Second).
 Setting zero value will cause the framerate to be at its maximum possible value.
 */
+ (NSUInteger)mjpegServerFramerate;
+ (void)setMjpegServerFramerate:(NSUInteger)framerate;

/**
 The quality of phone display screenshots. The higher quality you set is the bigger screenshot size is.
 The highest quality value is 0 (lossless PNG). The lowest quality is 2 (highly compressed JPEG).
 The default quality value is 1 (high quality JPEG).
 See https://developer.apple.com/documentation/xctest/xctimagequality?language=objc
 */
+ (NSUInteger)screenshotQuality;
+ (void)setScreenshotQuality:(NSUInteger)quality;

/**
 The range of ports that the HTTP Server should attempt to bind on launch
 */
+ (NSRange)bindingPortRange;

/**
 The port number where the background screenshots broadcaster is supposed to run
 */
+ (NSInteger)mjpegServerPort;

/**
 The scaling factor for frames of the mjpeg stream (Default values is 100 and does not perform scaling).
 */
+ (NSUInteger)mjpegScalingFactor;
+ (void)setMjpegScalingFactor:(NSUInteger)scalingFactor;

/**
 YES if verbose logging is enabled. NO otherwise.
 */
+ (BOOL)verboseLoggingEnabled;

+ (BOOL)shouldLoadSnapshotWithAttributes;

/**
 * Configure keyboards preference to make test running stable
 */
+ (void)configureDefaultKeyboardPreferences;

/**
 * Modify keyboard configuration of 'auto-correction'.
 *
 * @param isEnabled Turn the configuration on if the value is YES
 */
+ (void)setKeyboardAutocorrection:(BOOL)isEnabled;
+ (BOOL)keyboardAutocorrection;

/**
 * Modify keyboard configuration of 'predictive'
 *
 * @param isEnabled Turn the configuration on if the value is YES
 */
+ (void)setKeyboardPrediction:(BOOL)isEnabled;
+ (BOOL)keyboardPrediction;

/**
 * The maximum time to wait until accessibility snapshot is taken
 *
 * @param timeout The number of float seconds to wait (15 seconds by default)
 */
+ (void)setSnapshotTimeout:(NSTimeInterval)timeout;
+ (NSTimeInterval)snapshotTimeout;

/**
 Sets maximum depth for traversing elements tree from parents to children while requesting XCElementSnapshot.
 Used to set maxDepth value in a dictionary provided by XCAXClient_iOS's method defaultParams.
 The original XCAXClient_iOS maxDepth value is set to INT_MAX, which is too big for some queries
 (for example: searching elements inside a WebView).
 Reasonable values are from 15 to 100 (larger numbers make queries slower).

 @param maxDepth The number of maximum depth for traversing elements tree
 */
+ (void)setSnapshotMaxDepth:(int)maxDepth;

/**
  @return The number of maximum depth for traversing elements tree
 */
+ (int)snapshotMaxDepth;

/**
 Returns parameters for traversing elements tree from parents to children while requesting XCElementSnapshot.

 @return dictionary with parameters for element's snapshot request
*/
+ (NSDictionary *)snapshotRequestParameters;

/**
 * Whether to use fast search result matching while searching for elements.
 * By default this is disabled due to https://github.com/appium/appium/issues/10101
 * but it still makes sense to enable it for views containing large counts of elements
 *
 * @param enabled Either YES or NO
 */
+ (void)setUseFirstMatch:(BOOL)enabled;
+ (BOOL)useFirstMatch;

/**
 * Modify reduce motion configuration in accessibility.
 * It works only for Simulator since Real device has security model which allows chnaging preferences
 * only from settings app.
 *
 * @param isEnabled Turn the configuration on if the value is YES
 */
+ (void)setReduceMotionEnabled:(BOOL)isEnabled;
+ (BOOL)reduceMotionEnabled;

/**
 Enforces the page hierarchy to include non modal elements,
 like Contacts. By default such elements are not present there.
 See https://github.com/appium/appium/issues/13227

 @param isEnabled Set to YES in order to enable non modal elements inclusion.
 Setting this value to YES will have no effect if the current iOS SDK does not support such feature.
 */
+ (void)setIncludeNonModalElements:(BOOL)isEnabled;
+ (BOOL)includeNonModalElements;

/**
 Sets custom class chain locators for accept/dismiss alert buttons location.
 This might be useful if the default buttons detection algorithm fails to determine alert buttons properly
 when defaultAlertAction is set.

 @param classChainSelector Valid class chain locator, which determines accept/reject button
 on the alert. The search root is the alert element itself.
 Setting this value to nil or an empty string (the default
 value) will enforce WDA to apply the default algorithm for alert buttons location.
 If an invalid/non-parseable locator is set then the lookup will fallback to the default algorithm and print a
 warning into the log.
 Example: ** /XCUIElementTypeButton[`label CONTAINS[c] 'accept'`]
 */
+ (void)setAcceptAlertButtonSelector:(NSString *)classChainSelector;
+ (NSString *)acceptAlertButtonSelector;
+ (void)setDismissAlertButtonSelector:(NSString *)classChainSelector;
+ (NSString *)dismissAlertButtonSelector;

#if !TARGET_OS_TV
/**
 Set the screenshot orientation for iOS

 It helps to fix the screenshot orientation when the device under test's orientation changes.
 For example, when a device changes to the landscape, the screenshot orientation could be wrong.
 Then, this setting can force change the screenshot orientation.
 Xcode versions, OS versions or device models and simulator or real device could influence it.

 @param orientation Set the orientation to adjust the screenshot.
 Case insensitive "Portrait", "PortraitUpsideDown", "LandscapeRight" and "LandscapeLeft"  are available
 to force the coodinate adjust. Other wards are handled as "auto", which handles
 the adjustment automatically. Defaults to "auto".
 */
+ (void)setScreenshotOrientation:(NSString *)orientation;

/**
@return The value of UIInterfaceOrientation
*/
+ (NSInteger)screenshotOrientation;

/**
@return The orientation as String for human read
*/
+ (NSString *)screenshotOrientationForUser;

#endif

@end

NS_ASSUME_NONNULL_END
