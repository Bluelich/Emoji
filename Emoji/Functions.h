//
//  Functions.h
//  Emoji
//
//  Created by zhouqiang on 18/12/2017.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *k_unicode_org_xml;
FOUNDATION_EXPORT NSString *k_unicodey_com_xml;
FOUNDATION_EXPORT NSString *downloadXML(NSString *url);
FOUNDATION_EXPORT NSString *xmlDataForURL(NSString *url,BOOL ignore_cache);
