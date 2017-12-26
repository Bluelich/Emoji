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
    id jsonObject = all_emojis.yy_modelToJSONObject;
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingSortedKeys | NSJSONWritingPrettyPrinted error:&error];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"/org.json"];
    [JSONData writeToFile:path atomically:YES];
    printf("\ntotal:%ld",Emojis.org_count);
    printf("%s",all_emojis.description.UTF8String);
    [[NSRunLoop currentRunLoop] run];
    return 0;
}
