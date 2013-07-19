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
#define WHITE [UIColor whiteColor]
#define YELLOW [UIColor yellowColor]
#define TRANSPARENT [UIColor clearColor]
#define BLACK [UIColor blackColor]
#define RED [UIColor redColor]
#define BLUE [UIColor blueColor]
#define STEELBLUE [UIColor colorWithRed:70/256.f green:130/256.f blue:180/256.f alpha:1]

#if defined __MAC_OS_X_VERSION_MAX_ALLOWED
#define PLATFORM_OSX
#define UIApplicationDelegate NSApplicationDelegate
#define UIView NSView
#define UIApplication NSApplication

#elif defined __IPHONE_OS_VERSION_MAX_ALLOWED
#define PLATFORM_IOS
#endif

void error(NSError* err);
NSError* makeError(NSString* localMessage);

typedef void (^Block)();
typedef void (^Callback)(NSError* err, NSDictionary* res);
typedef void (^StringCallback)(NSError* err, NSString* res);
typedef void (^ArrayCallback)(NSError* err, NSArray* res);
typedef void (^DataCallback)(NSError* err, NSData* data);
typedef void (^ImageCallback)(NSError* err, UIImage* image);
typedef void (^ViewCallback)(NSError* err, UIView* view);
typedef void (^CGPointBlock)(CGPoint point);
typedef void (^CGPointVectorBlock)(CGPoint point, CGPoint vector);

void after(CGFloat delayInSeconds, Block block);
void vibrateDevice();

NSString* concat(id arg1, ...);
NSNumber* num(int i);
