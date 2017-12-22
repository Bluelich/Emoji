//
//  main.m
//  Emoji_Mac
//
//  Created by zhouqiang on 18/12/2017.
//

#import <Foundation/Foundation.h>
#import "Functions.h"
#import "Ono.h"
#import "Emoji.h"

int main(int argc, const char * argv[]) {
//    int a[4]={1,2,3,4};
//    int *ptr1 = (int *)(&a+1);
//    int *ptr2 = (int *)((int)a+1);
//    printf("%x,%x",ptr1[-1],*ptr2);
    
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
    NSNumber *total = [array valueForKeyPath:@"@sum.subCategories.emojis.@sum.@count"];
    printf("\ncount:%ld",total.integerValue);
    [[NSRunLoop currentRunLoop] run];
    return 0;
}
