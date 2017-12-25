//
//  Emoji.m
//  Emoji
//
//  Created by zhouqiang on 20/12/2017.
//

#import "Emoji.h"

@implementation EmojiImage
@end
@implementation EmojiDescription
@end

@implementation Emoji

- (instancetype)init{
    self = [super init];
    if (self) {
        self.subEmojis = [NSMutableArray array];
    }
    return self;
}

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

@implementation Emoji_Org
- (NSUInteger)count
{
    NSNumber *total = [self.all_emojis valueForKeyPath:@"@sum.subCategories.emojis.@sum.@count"];
    return total.unsignedIntegerValue;
}
@end
