//
//  main.m
//  Emoji_Mac
//
//  Created by zhouqiang on 18/12/2017.
//

#import <Foundation/Foundation.h>
#import "Emoji.h"
#import "NSObject+YYModel.h"

int main(int argc, const char * argv[]) {
//    int a[4]={1,2,3,4};
//    int *ptr1 = (int *)(&a+1);
//    int *ptr2 = (int *)((int)a+1);
//    printf("%x,%x",ptr1[-1],*ptr2);

    NSArray<EmojiCategory *> *all_emojis = Emojis.org;
    NSMutableArray *array = [NSMutableArray array];
    [all_emojis enumerateObjectsUsingBlock:^(EmojiCategory * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        [category.subCategories enumerateObjectsUsingBlock:^(EmojiSubCategory * _Nonnull subCategory, NSUInteger idx, BOOL * _Nonnull stop) {
            [subCategory.emojis enumerateObjectsUsingBlock:^(Emoji * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *arr = [obj.Code.name componentsSeparatedByString:@"_"];
                [array addObject:arr];
            }];
        }];
    }];
    id jsonObject = array.yy_modelToJSONObject;
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingSortedKeys | NSJSONWritingPrettyPrinted error:&error];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"/org.json"];
    [JSONData writeToFile:path atomically:YES];
    printf("\ntotal:%ld",Emojis.org_count);
    printf("%s",all_emojis.description.UTF8String);
    [[NSRunLoop currentRunLoop] run];
    return 0;
}
