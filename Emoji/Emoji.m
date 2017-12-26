//
//  Emoji.m
//  Emoji
//
//  Created by zhouqiang on 20/12/2017.
//

#import "Emoji.h"
#import <objc/runtime.h>
#import "Ono.h"

//U+指Unicode编码，数字为十六进制。
NSUInteger const kEmojiCount      = 2623;
NSUInteger const kEmojiCount_wiki = 1079;
NSString *kNumberKey     = @"value";
NSString *kStringKey     = @"string";
NSString *kFullStringKey = @"string_full";
NSString *kUnicode = @"unicode";
NSString *kDesc    = @"description";
NSString *kWiki    = @"wiki";
NSString *kEmoji   = @"emoji";

NSString *k_unicode_org_xml     = @"http://www.unicode.org/emoji/charts/full-emoji-list.html";
//https://github.com/iamcal/emoji-data
NSString *k_unicodey_com_xml    = @"https://unicodey.com/emoji-data/table.htm";


inline NSString *downloadXML(NSString *url);
inline NSString *xmlDataForURL(NSString *url,BOOL ignore_cache);
inline NSArray<EmojiCategory *> *all_emojis_org(BOOL forceUpdate);
inline NSString *propertyWithPrefix(NSString *prefix,Class class);

@implementation EmojiImage
@end
@implementation EmojiDescription
@end
@implementation Emoji
@end

@implementation EmojiSubCategory
- (instancetype)init{
    self = [super init];
    if (self) {
        self.emojis = [NSMutableArray array];
    }
    return self;
}
@end

@implementation EmojiCategory
- (instancetype)init
{
    self = [super init];
    if (self){
        self.subCategories = [NSMutableArray array];
    }
    return self;
}
@end

@implementation Emojis
+ (NSArray<EmojiCategory *> *)org
{
    static dispatch_once_t onceToken;
    static NSArray *array = nil;
    dispatch_once(&onceToken, ^{
        array = all_emojis_org(NO);
    });
    return array;
}
+ (NSUInteger)org_count
{
    NSNumber *total = [self.org valueForKeyPath:@"@sum.subCategories.@sum.emojis.@count"];
    if (total.unsignedIntegerValue != kEmojiCount) {
        printf("need update");
    }
    return total.unsignedIntegerValue;
}
@end

NSArray<EmojiCategory *> *all_emojis_org(BOOL forceUpdate){
    NSString *xml = xmlDataForURL(k_unicode_org_xml, forceUpdate);
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:&error];
    ONOXMLElement *body = [document.rootElement firstChildWithTag:@"body"];
    ONOXMLElement *main = nil;
    for (ONOXMLElement *element in body.children) {
        if ([[element.attributes objectForKey:@"class"] isEqualToString:@"main"]) {
            main = element;
        }
    }
    NSMutableArray<EmojiCategory *> *array = [NSMutableArray array];
    {
        EmojiCategory    *category    = nil;
        EmojiSubCategory *subCategory = nil;
        NSMutableArray   *platforms   = [NSMutableArray array];
        for (ONOXMLElement *obj in [document XPath:@"//table[1]//tr"]){
            Emoji *emoji = nil;
            NSArray<ONOXMLElement *> *children = obj.children;
            for (short i = 0; i < children.count; i++) {
                ONOXMLElement *element = children[i];
                NSString *class  = element.attributes[@"class"];
                NSString *value  = element.stringValue;
                ONOXMLElement *a = [element firstChildWithTag:@"a"];
                NSString *href   = a.attributes[@"href"];
                NSString *name   = a.attributes[@"name"];
                if (a) value = a.stringValue;
                if ([element.tag isEqualToString:@"th"]) {
                    if ([class isEqualToString:@"bighead"]) {
                        category = [EmojiCategory new];
#if Emoji_Debug
                        category.class_= class;
#endif
                        category.href = href;
                        category.name = name;
                        category.category = value;
                        [array addObject:category];
                    }else if ([class isEqualToString:@"mediumhead"]){
                        subCategory = [EmojiSubCategory new];
#if Emoji_Debug
                        subCategory.class_= class;
#endif
                        subCategory.subCategory = value;
                        subCategory.href = href;
                        subCategory.name = name;
                        [category.subCategories addObject:subCategory];
                        platforms = [NSMutableArray array];
                    }else{
                        [platforms addObject:value];
                    }
                }else if ([element.tag isEqualToString:@"td"]){
                    if (!emoji) {
                        emoji = [Emoji new];
                        [subCategory.emojis addObject:emoji];
                    }
                    if ([class containsString:@"miss"]) {
                        continue;
                    }
                    NSString *platform = platforms[i];
                    platform = propertyWithPrefix(platform, [Emoji class]) ?: platform;
                    EmojiDescription *desc = [EmojiDescription new];
#if Emoji_Debug
                    desc.class_ = class;
#endif
                    if (value.length > 0) {
                        desc.value  = value;
                    }
                    if (a) {
                        desc.href = href;
                        desc.name = name;
                    }
                    ONOXMLElement *imgElement = [element firstChildWithTag:@"img"];
                    if (imgElement) {
                        EmojiImage *img = [EmojiImage new];
                        img.src   = imgElement.attributes[@"src"];
                        img.alt   = imgElement.attributes[@"alt"];
#if Emoji_Debug
                        img.class_ = imgElement.attributes[@"class"];
#endif
                        desc.img = img;
                    }
                    [emoji setValue:desc forKey:platform];
                }
            }
        }
    }
    return array;
}
NSString *propertyWithPrefix(NSString *prefix,Class class){
    static NSMutableDictionary<NSString *,NSMutableArray *> *properties = nil;
    static dispatch_once_t onceToken;
    static NSDictionary *abbr_vendor = nil;
    dispatch_once(&onceToken, ^{
        properties = [NSMutableDictionary dictionary];
        abbr_vendor = @{@"Sample":@"Chosen for illustration, from available images.",
                        @"Apple":@"Apple",
                        @"Goog.":@"Google",
                        @"Twtr":@"Twitter",
                        @"One":@"EmojiOne",
                        @"FB":@"Facebook",
                        @"FBM":@"Messenger",
                        @"Wind.":@"Windows",
                        @"Sams.":@"Samsung",
                        @"GMail":@"GMail",
                        @"DCM":@"DoCoMo",
                        @"KDDI":@"KDDI",
                        @"SB":@"SoftBank",
                        @"CLDR Short Name":@"CLDR_Short_Name"
                        };
    });
    NSString *className = NSStringFromClass(class);
    NSMutableArray *propertiesForClass = [properties objectForKey:className];
    if (!propertiesForClass) {
        @synchronized(class){
            propertiesForClass = [NSMutableArray array];
            unsigned int outCount = 0;
            objc_property_t *propertyList = class_copyPropertyList(class, &outCount);
            for (unsigned int i = 0; i < outCount; i++) {
                const char *name =  property_getName(propertyList[i]);
                [propertiesForClass addObject:[NSString stringWithUTF8String:name]];
            }
            if (propertyList) {
                free(propertyList);
            }
        }
    }
    for (NSString *name in propertiesForClass) {
        if ([name.uppercaseString hasPrefix:prefix.uppercaseString]) {
            return name;
        }else{
            NSString *vendor = [abbr_vendor objectForKey:prefix];
            if ([vendor.uppercaseString isEqualToString:name.uppercaseString]) {
                return name;
            }
        }
    }
    return nil;
}
NSString *pathForURL(NSString *url){
    NSString *fileName = [NSString stringWithFormat:@"%lud",url.hash];
    NSString *path = [[NSTemporaryDirectory() stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"html"];
    return path;
}
NSString *xmlDataForURL(NSString *url,BOOL ignore_cache){
    if (ignore_cache) {
        return downloadXML(url);
    }
    NSString *path = pathForURL(url);
    NSError *error = nil;
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!error && str.length > 0) {
        return str;
    }
    return downloadXML(url);;
}
BOOL saveXML(NSString *xml,NSString *url){
    NSString *path = pathForURL(url);
    NSError *error = nil;
    if (![xml writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        printf("\nerror:%s",error.description.UTF8String);
        return NO;
    }
    return YES;
}
NSString *downloadXML(NSString *url){
    if (![url isKindOfClass:NSString.class] || url.length == 0) {
        return nil;
    }
    __block NSString *retval = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        retval = string;
        dispatch_semaphore_signal(semaphore);
    }]resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (retval && retval.length > 0) {
        saveXML(retval, url);
    }
    return retval;
}
NSString *EmojiRegex(){
    /*
     //EBNF
     
     200D : joiner
     RI   : Regional_Indicator
     Mn   : Nonspacing_Mark
     FE0F : emoji VS
     E00xx: tags
     E007F: the TERM tag.
     
     possible_emoji := possible_zwj_element (\x{200D} possible_zwj_element)+
     
     possible_zwj_element :=
        \p{RI} \p{RI}
     | \p{Emoji} emoji_modification?
     
     emoji_modification :=
        \p{EMD}
     | \x{FE0F}? \p{Mn}*
     | [\x{E0020}-\x{E007E}]+ \x{E007F}
     
     //Regex
     (\p{Regional_Indicator} \p{Regional_Indicator}
     | \p{Emoji} (\p{Emoji_Modifier} | \x{FE0F}? \p{Nonspacing_Mark}* | [\x{E0020}-\x{E007E}]+ \x{E007F})?)
        ( \x{200D}
     (\p{Regional_Indicator} \p{Regional_Indicator}
     | \p{Emoji} (\p{Emoji_Modifier} | \x{FE0F}? \p{Nonspacing_Mark}* | [\x{E0020}-\x{E007E}]+ \x{E007F})?))+
     
     */
    /*
     U+200D零宽连字符 (zero-width joiner，ZWJ)是一个不打印字符，放在某些需要复杂排版语言（如阿拉伯语、印地语）的两个字符之间，使得这两个本不会发生连字的字符产生了连字效果。零宽连字符的Unicode码位是U+200D (HTML: &#8205; &zwj;）。
     U+1F468(男人) + U+200D(ZWJ) + U+1F469(女人) + U+200D(ZWJ) + U+1F467(女孩) = 👨‍👩‍👧
     如果不支持ZWJ,则ZWJ会被忽略,显示👨👩👧
     
     */
    return @"";
}
