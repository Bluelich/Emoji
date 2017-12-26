//
//  Functions.m
//  Emoji
//
//  Created by zhouqiang on 18/12/2017.
//

#import "Functions.h"
#import <mach-o/dyld.h>

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
