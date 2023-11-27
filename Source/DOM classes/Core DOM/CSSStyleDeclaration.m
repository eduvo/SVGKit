#import "CSSStyleDeclaration.h"

#import "CSSValue.h"
#import "CSSValueList.h"
#import "CSSPrimitiveValue.h"
#import "CocoaLumberjack/DDFileLogger.h"

#import "SVGKDefine_Private.h"

@interface CSSStyleDeclaration()

@property(nonatomic,strong) NSMutableDictionary* internalDictionaryOfStylesByCSSClass;

@end

@implementation CSSStyleDeclaration

@synthesize internalDictionaryOfStylesByCSSClass;

@synthesize cssText = _cssText;
@synthesize length;
@synthesize parentRule;


- (id)init
{
    self = [super init];
    if (self) {
        self.internalDictionaryOfStylesByCSSClass = [NSMutableDictionary dictionary];
    }
    return self;
}

#define MAX_ACCUM 256
#define MAX_NAME 256

/** From spec:
 
 "The parsable textual representation of the declaration block (excluding the surrounding curly braces). Setting this attribute will result in the parsing of the new value and resetting of all the properties in the declaration block including the removal or addition of properties."
 */
-(void)setCssText:(NSString *)newCSSText
{
	_cssText = newCSSText;
	
	/** and now post-process it, *as required by* the CSS/DOM spec... */
	NSMutableDictionary* processedStyles = [self NSDictionaryFromCSSAttributes:_cssText];
	
	self.internalDictionaryOfStylesByCSSClass = processedStyles;
  
}

-(NSMutableDictionary *) NSDictionaryFromCSSAttributes: (NSString *) cssString {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSCharacterSet* trimChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSArray *properties = [cssString componentsSeparatedByString: @";"];

    for (NSString *property in properties) {
        NSArray *keyValuePair = [property componentsSeparatedByString:@":"];
        if (keyValuePair.count == 2) {
            NSString *key = [keyValuePair[0] stringByTrimmingCharactersInSet:trimChars];
            NSString *value = [keyValuePair[1] stringByTrimmingCharactersInSet:trimChars];
            [dict setObject:value forKey:key];
        }
    }

    return dict;
}

-(NSString*) getPropertyValue:(NSString*) propertyName
{
	CSSValue* v = [self getPropertyCSSValue:propertyName];
	
	if( v == nil )
		return nil;
	else
		return v.cssText;
}

-(CSSValue*) getPropertyCSSValue:(NSString*) propertyName
{
	return [self.internalDictionaryOfStylesByCSSClass objectForKey:propertyName];
}

-(NSString*) removeProperty:(NSString*) propertyName
{
	NSString* oldValue = [self getPropertyValue:propertyName];
	[self.internalDictionaryOfStylesByCSSClass removeObjectForKey:propertyName];
	return oldValue;
}

-(NSString*) getPropertyPriority:(NSString*) propertyName
{
	NSAssert(FALSE, @"CSS 'property priorities' - Not supported");
	
	return nil;
}

-(void) setProperty:(NSString*) propertyName value:(NSString*) value priority:(NSString*) priority
{
	NSAssert(FALSE, @"CSS 'property priorities' - Not supported");
}

-(NSString*) item:(long) index
{
	/** this is stupid slow, but until Apple *can be bothered* to add a "stable-order" dictionary to their libraries, this is the only sensibly easy way of implementing this method */
	NSArray* sortedKeys = [[self.internalDictionaryOfStylesByCSSClass allKeys] sortedArrayUsingSelector:@selector(compare:)];
	CSSValue* v = [sortedKeys objectAtIndex:index];
	return v.cssText;
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"CSSStyleDeclaration: dictionary(%@)", self.internalDictionaryOfStylesByCSSClass];
}

@end
