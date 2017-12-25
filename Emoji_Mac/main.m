//
//  main.m
//  Emoji_Mac
//
//  Created by zhouqiang on 18/12/2017.
//

#import <Foundation/Foundation.h>
#import "Functions.h"

int main(int argc, const char * argv[]) {
//    int a[4]={1,2,3,4};
//    int *ptr1 = (int *)(&a+1);
//    int *ptr2 = (int *)((int)a+1);
//    printf("%x,%x",ptr1[-1],*ptr2);
    
    Emoji_Org *all_emojis = all_emojis_org();
    [all_emojis.all_emojis enumerateObjectsUsingBlock:^(EmojiCategory * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        [category.subCategories enumerateObjectsUsingBlock:^(EmojiSubCategory * _Nonnull subCategory, NSUInteger idx, BOOL * _Nonnull stop) {
            [subCategory.emojis enumerateObjectsUsingBlock:^(Emoji * _Nonnull emoji, NSUInteger idx, BOOL * _Nonnull stop) {
                [emoji.subEmojis enumerateObjectsUsingBlock:^(EmojiDescription * _Nonnull emojiDescription, NSUInteger idx, BOOL * _Nonnull stop) {
                    printf("\n%s->%s->%s:%s",category.name.UTF8String,subCategory.name.UTF8String,emojiDescription.platform.UTF8String,emojiDescription.desc.UTF8String);
                }];
            }];
        }];
    }];
    printf("\ntotal:%ld",all_emojis.count);
    [[NSRunLoop currentRunLoop] run];
    return 0;
}
