#define MODE_DEV 1
#define MODE_TESTFLIGHT 2
#define MODE_DISTRIBUTION 3
#if defined TESTFLIGHT
    #define MODE MODE_TESTFLIGHT
#elif defined DEBUG
    #define MODE MODE_DEV
#else
    #define MODE MODE_DISTRIBUTION
#endif
#define IS_DISTRIBUTION (MODE == MODE_DISTRIBUTION)


#define CLIP(X,min,max) MIN(MAX(X, min), max)

#if defined __MAC_OS_X_VERSION_MAX_ALLOWED
#define PLATFORM_OSX
#define UIApplicationDelegate NSApplicationDelegate
#define UIView NSView
#define UIApplication NSApplication

#elif defined __IPHONE_OS_VERSION_MAX_ALLOWED
#define PLATFORM_IOS
#endif

#include "TargetConditionals.h"

#if TARGET_IPHONE_SIMULATOR
static const BOOL isSimulator = YES;
#else
static const BOOL isSimulator = NO;
#endif

typedef void (^Block)();
typedef void (^Callback)(NSError* err, NSDictionary* res);
typedef void (^StringCallback)(NSError* err, NSString* res);
typedef void (^ArrayCallback)(NSError* err, NSArray* res);
typedef void (^DataCallback)(NSError* err, NSData* data);
typedef void (^ImageCallback)(NSError* err, UIImage* image);
typedef void (^ViewCallback)(NSError* err, UIView* view);
typedef void (^CGPointBlock)(CGPoint point);
typedef void (^CGPointVectorBlock)(CGPoint point, CGPoint vector);
typedef void (^NSUIntegerBlock)(NSUInteger i);

void error(NSError* err);
NSError* makeError(NSString* localMessage);
void after(NSTimeInterval delayInSeconds, Block block);
void asyncDefault(Block block);
void asyncHigh(Block block);
void asyncLow(Block block);
void asyncMain(Block block);
void asyncBackground(Block block);
void vibrateDevice();
NSString* concat(id arg1, ...);
NSNumber* num(int i);
NSNumber* numf(float f);
void repeat(NSUInteger times, NSUIntegerBlock block);
