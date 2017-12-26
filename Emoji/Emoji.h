//
//  Emoji.h
//  Emoji
//
//  Created by zhouqiang on 20/12/2017.
//

#import <Foundation/Foundation.h>

#define Emoji_Debug 0
#if Emoji_Debug
    #define Property_Class @property(nonatomic,strong)NSString*class_
#else
    #define Property_Class
#endif

@interface EmojiImage : NSObject
Property_Class;
@property (nonatomic,strong) NSString  *alt;
@property (nonatomic,strong) NSString  *src;
@end

@interface EmojiDescription : NSObject
Property_Class;
@property (nonatomic,strong) NSString  *value;
@property (nonatomic,strong) NSString  *href;
@property (nonatomic,strong) NSString  *name;
@property (nonatomic,strong) EmojiImage*img;
@end

@interface Emoji : NSObject
@property (nonatomic,strong) EmojiDescription  *№;
@property (nonatomic,strong) EmojiDescription  *Code;
@property (nonatomic,strong) EmojiDescription  *Browser;
@property (nonatomic,strong) EmojiDescription  *Apple;
@property (nonatomic,strong) EmojiDescription  *Google;
@property (nonatomic,strong) EmojiDescription  *Twitter;
@property (nonatomic,strong) EmojiDescription  *EmojiOne;
@property (nonatomic,strong) EmojiDescription  *Facebook;
@property (nonatomic,strong) EmojiDescription  *Samsung;
@property (nonatomic,strong) EmojiDescription  *Windows;
@property (nonatomic,strong) EmojiDescription  *Gmail;
@property (nonatomic,strong) EmojiDescription  *SoftBank;
@property (nonatomic,strong) EmojiDescription  *DoCoMo;
@property (nonatomic,strong) EmojiDescription  *KDDI;
@property (nonatomic,strong) EmojiDescription  *CLDR_Short_Name;
@end

@interface EmojiSubCategory : NSObject
Property_Class;
@property (nonatomic,strong) NSString  *subCategory;
@property (nonatomic,strong) NSString  *href;
@property (nonatomic,strong) NSString  *name;
@property (nonatomic,strong) NSMutableArray<Emoji *> *emojis;
@end


@interface EmojiCategory : NSObject
Property_Class;
@property (nonatomic,strong) NSString  *category;
@property (nonatomic,strong) NSString  *href;
@property (nonatomic,strong) NSString  *name;
@property (nonatomic,strong) NSMutableArray<EmojiSubCategory *> *subCategories;
@end

@interface Emojis : NSObject
@property (nonatomic,strong,readonly,class) NSArray<EmojiCategory *> *org;
@property (nonatomic,assign,readonly,class) NSUInteger org_count;
@end
