#import "FISWebViewPreloader.h"
#import "FISPreloadItem.h"

@interface FISWebViewPreloader ()

@property (strong, nonatomic) NSMutableDictionary *preloadManager;
@property (nonatomic) NSInteger capacity;
@end

@implementation FISWebViewPreloader

- (id)init
{
    self = [super init];
    
    if(self) {
        [self reset];
        _capacity = NSIntegerMax;
    }
    
    return self;
}

- (id)initWithCapacity:(NSInteger)capacity
{
    self = [[FISWebViewPreloader alloc] init];
    if (self) {
        _capacity = capacity;
    }
    return self;
}

- (UIWebView *)setURLString:(NSString *)aURLString forKey:(id<NSCopying>)aKey withCGRect:(CGRect)cgRect
{
    if ([[self allKeys] count] >= self.capacity) {
        [self unloadWebViewForKey:[self.priorityQueue lastObject]];
    }
    
    FISPreloadItem *preloadItem = [[FISPreloadItem alloc] initWithURLString:aURLString
                                                                 withCGRect:cgRect];
     
    [self.preloadManager setObject:preloadItem forKey:aKey];
    [self.priorityQueue insertObject:aKey atIndex:0];

    return [preloadItem webView];
}


- (UIWebView *)setURLString:(NSString *)aURLString forKey:(id<NSCopying>)aKey
{
    return [self setURLString:aURLString forKey:aKey withCGRect:CGRectNull];
}

- (UIWebView *)webViewForKey:(id<NSCopying>)aKey
{
    //Move object to front of priority queue if accessed
    [self.priorityQueue removeObject:aKey];
    [self.priorityQueue insertObject:aKey atIndex:0];
    
    FISPreloadItem *preloadItem = self.preloadManager[aKey];

    return preloadItem.webView;
}


- (void)unloadWebViewForKey:(id<NSCopying>)aKey
{    
    FISPreloadItem *preloadItem = self.preloadManager[aKey];
    [preloadItem unloadWebView];
    [self.priorityQueue removeObject:aKey];

}

- (NSArray *)allKeys
{
    return [self.preloadManager allKeys];
}

- (void)reset
{
    self.preloadManager = [[NSMutableDictionary alloc] init];
    self.priorityQueue = [[NSMutableArray alloc] init];
}


@end
