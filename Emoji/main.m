//
//  main.m
//  Emoji
//
//  Created by zhouqiang on 30/10/2017.
//  Copyright © 2017 Bluelich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+YYModel.h"
#import <mach-o/dyld.h>

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

NSString *kFull_emoji_list = @"http://www.unicode.org/emoji/charts/full-emoji-list.html";

NSString *getStrWith(NSString *str){
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
/*
 00a9 00ae
 203c
 2049
 2122
 2139
 2194-2199
 21a9-21aa
 231a-231b
 2328
 23cf
 23e9-23ef
 23f0-23f3  23f8-23fa
 24c2
 25aa-25ab
 25b6
 25c0
 25fb-25fe
 2600-2604 260e
 2611 2614-2615 2618 261d
 2620 2622-2623 2626 262a 262e-262f
 2638-263a
 2640 2642 2648-264f
 2650-2653
 2660 2663 2665-2666 2668
 267b 267f
 2692-2697 2699 269b-269c

 26a0-26a1 26aa-26ab
 26b0-26b1 26bd-26be
 26c4-26c5 26c8 26ce-26cf
 26d1 26d3-26d4
 26e9-26ea
 26f0-26f5 26f7-26fa 26fd
 2702 2705 2708-270d 270f
 2712 2714
 
 */
//NSString *regStringFromArray(NSArray<NSArray<NSDictionary<NSString *,id> *> *> *array){
//    NSMutableString *string = [NSMutableString string];
//    [array enumerateObjectsUsingBlock:^(NSArray<NSDictionary *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.count == 1) {
//            NSString *a = obj.firstObject.allValues.firstObject;
//
//        }else if (obj.count == 2){
//            NSString *a = obj.firstObject.allValues.firstObject;
//            NSString *b = obj.lastObject.allValues.firstObject;
//        }else{
//            NSString *from = [obj.firstObject objectForKey:@""];
//            NSString *to   = obj.lastObject.allValues.firstObject;
//        }
//    }];
//    return @"";
//}
NSUInteger count1(NSArray<NSArray<NSDictionary<NSString *,id> *> *> *array){
    __block NSInteger count = 0;
    [array enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        count += obj.count;
    }];
    NSLog(@"count:%ld",count);
    return count;
}
BOOL checkCount(NSArray<NSArray<NSDictionary<NSString *,id> *> *> *array,NSUInteger count){
    if (count1(array) == count) {
        NSLog(@"⭕️");
        return YES;
    }else{
        NSLog(@"❌");
        return NO;
    }
}
void checkLocalData(NSUInteger total,NSString *full_fileName){
    NSString *path_data = [@"/Users/zhouqiang/Desktop/str/str/" stringByAppendingString:full_fileName];
    NSString *string = [NSString stringWithContentsOfFile:path_data encoding:NSUTF8StringEncoding error:nil];
    NSData   *data   = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array   = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    checkCount(array, total);
    return;
}
void writeToFile(NSArray<NSArray<NSDictionary<NSString *,id> *> *> *array,NSString *full_fileName){
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *path = [@"/Users/zhouqiang/Desktop/str/str/" stringByAppendingString:full_fileName];
    [data writeToFile:path atomically:YES];
}
void textToArrayJSON(){
    NSString *str = [NSString stringWithContentsOfFile:@"/Users/zhouqiang/Desktop/str/str/emoji_all.txt" encoding:NSUTF8StringEncoding error:nil];
    NSArray<NSString *> *list = [str componentsSeparatedByString:@"\n"];
    
    NSMutableArray<NSArray<NSDictionary<NSString *,id> *> *> *array = [NSMutableArray array];
    __block NSMutableArray<NSDictionary<NSString *,id> *> *subArray = [NSMutableArray array];
    __block unsigned prefix   = 0;
    [list enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        NSString *p = [obj componentsSeparatedByString:@"_"].firstObject;
        NSScanner *scanner = [NSScanner scannerWithString:p];
        unsigned pre = 0;
        [scanner scanHexInt:&pre];
        if (pre != prefix && pre != prefix + 1) {
            subArray = [NSMutableArray array];
            [array addObject:subArray];
        }
        prefix = pre;
        NSDictionary *dic = @{
                              kNumberKey:@(pre),
                              kStringKey:p,
                              kFullStringKey:obj
                              };
        [subArray addObject:dic];
    }];
    checkCount(array,kEmojiCount);
}
void wiki(){
    NSString *str = [NSString stringWithContentsOfFile:@"/Users/zhouqiang/Desktop/str/str/emoji_wiki2.html" encoding:NSUTF8StringEncoding error:nil];
    NSArray<NSString *> *list = [str componentsSeparatedByString:@"[Prefix]"];
    NSMutableArray<NSDictionary<NSString *,id> *> *total = [NSMutableArray array];
    list = [list subarrayWithRange:NSMakeRange(1, list.count - 1)];
    NSMutableArray<NSArray *> *all = [NSMutableArray array];
    [list enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray<NSString *> *arr = [obj componentsSeparatedByString:@"\n"].mutableCopy;
        NSString *prefix = [arr.firstObject stringByReplacingOccurrencesOfString:@"x" withString:@"0"];
        NSScanner *scanner = [NSScanner scannerWithString:prefix];
        unsigned value = 0;
        [scanner scanHexInt:&value];
        [arr removeObjectAtIndex:0];
        [arr removeLastObject];
        if (arr.count != 16) {
            NSLog(@"");
        }
        NSMutableArray<NSDictionary *> *subArray = [NSMutableArray array];
        for (int i = 0x0; i < 0xf; i++) {
            NSString *s = arr[i];
            if ([s isEqualToString:@"[Empty]"]) {
                continue;
            }
            NSArray<NSString *> *array = [s componentsSeparatedByString:@": "];
            NSString *_unicode = [NSString stringWithFormat:@"%04X",value + i];
            NSString *unicode = array.firstObject.copy;
            if (![unicode isEqualToString:_unicode]) {
                NSLog(@"");
            }
            array = [array.lastObject componentsSeparatedByString:@"\"><a href=\""];
            NSString *desc = array.firstObject.copy;
            array = [array.lastObject componentsSeparatedByString:@"\" title=\""];
            NSString *href = array.firstObject;
            NSString *wiki = [@"https://en.wikipedia.org" stringByAppendingString:href];
            array = [array.lastObject componentsSeparatedByString:@"\">"];
            NSString *emoji = array.lastObject;
            NSDictionary *dic = @{
                                  kUnicode:unicode,
                                  kDesc:desc,
                                  kWiki:wiki,
                                  kEmoji:emoji
                                  };
            [subArray addObject:dic];
            [total addObject:dic];
        }
        if (subArray.count > 0) {
            [all addObject:subArray];
        }
    }];
    if (checkCount(all, kEmojiCount_wiki)) {
        __block unsigned pre   = 0x00a9 - 1;
        __block  unsigned start = 0x00a9;
        NSMutableArray<NSString *> *array = [NSMutableArray array];
        [total enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx > 1070) {
                NSLog(@"");
            }
            NSScanner *scanner = [NSScanner scannerWithString:obj[kUnicode]];
            unsigned value = 0;
            [scanner scanHexInt:&value];
            if (value != pre + 1) {
                if (start && start == pre) {
                    [array addObject:[NSString stringWithFormat:@"%04x",pre]];
                }else{
                    [array addObject:[NSString stringWithFormat:@"%04x-%04x",start,pre]];
                }
                start = value;
            }
            pre = value;
        }];
        NSLog(@"");
    }
    //    writeToFile(all, @"emoji_wiki.json");
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
void uncoide_org(){
        
}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        defaultEmoticons();
        NSURL *url = [NSURL URLWithString:kFull_emoji_list];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"");
        }]resume];
        NSRunLoop.currentRunLoop.run;
        return 0;
        /*
//        wiki();
        NSString *emoji = @"🙆🏻‍♂️";
        const char *utf16 = [emoji cStringUsingEncoding:NSUTF16StringEncoding];
        const char *unicode = [emoji cStringUsingEncoding:NSUnicodeStringEncoding];
        printf("utf16:%s  \nunicode:%s\n",utf16,unicode);
        char fnameStr[emoji.length];
        memcpy(fnameStr, [emoji cStringUsingEncoding:NSUnicodeStringEncoding], emoji.length * 2);
        [emoji enumerateSubstringsInRange:NSMakeRange(0, emoji.length)  options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            NSString *aa = emoji;
            unichar char1 = [substring characterAtIndex:0];
            unichar c;
            [substring getCharacters:&c];
            c = 0;
            [@"哈哈" getCharacters:&c];
            NSLog(@"");
        }];
         */
    }
    return 0;
}

/*
 NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"http:\/\/www\.unicode\.org\/emoji\/charts\/emoji\-list\.html#(\\w{5})" options:NSRegularExpressionCaseInsensitive error:nil];
 */
