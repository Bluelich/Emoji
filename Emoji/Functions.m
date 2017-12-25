//
//  Functions.m
//  Emoji
//
//  Created by zhouqiang on 18/12/2017.
//

#import "Functions.h"
#import <mach-o/dyld.h>
#import "Ono.h"

//U+指Unicode编码，数字为十六进制。
static NSUInteger kEmojiCount      = 2623;
static NSUInteger kEmojiCount_wiki = 1079;
NSString *kNumberKey     = @"value";
NSString *kStringKey     = @"string";
NSString *kFullStringKey = @"string_full";

NSString *kUnicode = @"unicode";
NSString *kDesc    = @"description";
NSString *kWiki    = @"wiki";
NSString *kEmoji   = @"emoji";

NSString *k_unicode_org_xml = @"http://www.unicode.org/emoji/charts/full-emoji-list.html";
//https://github.com/iamcal/emoji-data
NSString *k_unicodey_com_xml    = @"https://unicodey.com/emoji-data/table.htm";

Emoji_Org *all_emojis_org(){
    NSString *xml = xmlDataForURL(k_unicode_org_xml, NO);
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
    EmojiCategory    *category    = nil;
    EmojiSubCategory *subCategory = nil;
    for (ONOXMLElement *obj in [document XPath:@"//table[1]//tr"]) {
        Emoji *emoji = nil;
        for (ONOXMLElement *element in obj.children) {
            //            printf("tag:%s attr:%s\n",element.tag.UTF8String,element.attributes.description.UTF8String);
            ONOXMLElement *a = [element firstChildWithTag:@"a"];
            NSString *class  = element.attributes[@"class"];
            NSString *href   = a.attributes[@"href"];
            NSString *name   = a.attributes[@"name"];
            NSString *target = a.attributes[@"target"];
            NSString *value  = a.stringValue;
            if ([element.tag isEqualToString:@"th"]) {
                if ([class isEqualToString:@"bighead"]) {
                    category = [EmojiCategory new];
                    category.href = href;
                    category.name = name;
                    category.category = value;
                    category.class= class;
                    [array addObject:category];
                }else if ([class isEqualToString:@"mediumhead"]){
                    subCategory = [EmojiSubCategory new];
                    subCategory.subCategory = value;
                    subCategory.href = href;
                    subCategory.name = name;
                    subCategory.class= class;
                    [category.subCategories addObject:subCategory];
                }else if ([class isEqualToString:@"rchars"]){
                    printf("");
                }
            }else if ([element.tag isEqualToString:@"td"]){
                if (!emoji) {
                    emoji = [Emoji new];
                    [subCategory.emojis addObject:emoji];
                }
                EmojiDescription *desc = [EmojiDescription new];
                desc.class = class;
                desc.desc  = value;
                ONOXMLElement *imgElement = [element firstChildWithTag:@"img"];
                if (imgElement) {
                    EmojiImage *img = [EmojiImage new];
                    img.src   = imgElement.attributes[@"src"];
                    img.alt   = imgElement.attributes[@"alt"];
                    img.class = imgElement.attributes[@"class"];
                    desc.img = img;
                }
                [emoji.subEmojis addObject:desc];
                printf("");
            }else{
                printf("");
            }
        }
    }
    Emoji_Org *org = [Emoji_Org new];
    org.all_emojis = array;
    return org;
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

NSString* getExcutePath(){
    char *buf = NULL;
    uint32_t size = 0;
    _NSGetExecutablePath(buf,&size);
    char* path = (char*)malloc(size+1);
    path[size] = 0;
    _NSGetExecutablePath(path,&size);
    char* pCur = strrchr(path, '/');
    NSString* nsPath = [NSString stringWithUTF8String:path];
    free(path);
    path = NULL;
    *pCur = 0;
    return nsPath;
}
int emoji_unicode_to_symbol(int unicode){
    int result = 0x808080F0 | (unicode & 0x3F000) >> 4;
    result |= (unicode & 0xFC0) << 10;
    result |= (unicode & 0x1C0000) << 18;
    result |= (unicode & 0x3F) << 24;
    return result;
}
//获取默认表情数组
NSArray *defaultEmoticons(){
    NSMutableArray *array = [NSMutableArray array];
    int start = 0x1f600;
    int end = 0x1F64F;
    //    int exclude_left = 0x1F641;
    //    int exclude_right = 0x1F644;
    //    start = 0x00a0;
    //    end   = 0x1f9ef;
    for (int i = start; i <= end; i++) {
        if (i >= 0x1F641 && i <= 0x1F644) {
            continue;
        }
        int sym = emoji_unicode_to_symbol(i);
        NSString *emoT = [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
        [array addObject:emoT];
    }
    return array;
}
/**
 未完全处理

 @param str source
 @return result
 */
NSString *getStrWithoutEmoji(NSString *str){
    NSMutableString *string = [NSMutableString stringWithString:str];
    [string enumerateSubstringsInRange:NSMakeRange(0, str.length) options:NSStringEnumerationByComposedCharacterSequences|NSStringEnumerationReverse usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        BOOL delete = NO;
        const unichar hs = [substring characterAtIndex:0];
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    delete = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                delete = YES;
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff) {
                delete = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                delete = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                delete = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                delete = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                delete = YES;
            }
        }
        if (delete) {
            [string deleteCharactersInRange:substringRange];
        }
    }];
    return string.copy;
}
