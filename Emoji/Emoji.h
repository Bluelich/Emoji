//
//  Emoji.h
//  Emoji
//
//  Created by zhouqiang on 20/12/2017.
//

#import <Foundation/Foundation.h>

@interface EmojiImage : NSObject
@property (nonatomic,strong) NSString  *class;
@property (nonatomic,strong) NSString  *alt;
@property (nonatomic,strong) NSString  *src;
@end

@interface EmojiDescription : NSObject
@property (nonatomic,strong) NSString  *class;
@property (nonatomic,strong) NSString  *platform;
@property (nonatomic,strong) NSString  *desc;
@property (nonatomic,strong) EmojiImage*img;
@end

@interface Emoji : NSObject
@property (nonatomic,strong) NSMutableArray<EmojiDescription *> *subEmojis;
@end

@interface EmojiSubCategory : NSObject
@property (nonatomic,strong) NSString  *class;
@property (nonatomic,strong) NSString  *subCategory;
@property (nonatomic,strong) NSString  *href;
@property (nonatomic,strong) NSString  *name;
@property (nonatomic,strong) NSMutableArray<Emoji *> *emojis;
@end


@interface EmojiCategory : NSObject
@property (nonatomic,strong) NSString  *class;
@property (nonatomic,strong) NSString  *category;
@property (nonatomic,strong) NSString  *href;
@property (nonatomic,strong) NSString  *name;
@property (nonatomic,strong) NSMutableArray<EmojiSubCategory *> *subCategories;
@end

@interface Emoji_Org : NSObject
@property (nonatomic,strong) NSArray<EmojiCategory *> *all_emojis;
@property (nonatomic,assign,readonly)NSUInteger count;
@end
