//
//  NSDate+NSString.h
//  StateMachine
//
//  Created by cqh on 15/5/6.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSString)


/**
 *  返回一个某种格式的时间字符串
 *
 *  @param formatterString 时间格式
 *
 *  @return 时间字符处
 */

+ (NSString *)dateWithFormatterString:(NSString *)formatterString;

/**
 *  
     将本地的时间字符串
     IN: 2015-07-17 16:01:40
     
     转为GMT格式(格林威治标准时间)
     Out:周五, 17 07 2015 08:01:40 GMT
 *
 */
+ (NSString *)GMTDateFormatStringWithLocalDateString:(NSString *)localDateString;

/**
 *   将本地的时间字符串
 IN: 2015-07-17 16:01:40
 
 转为GMT格式(格林威治标准时间)
 Out:wed, 17 07 2015 08:01:40 GMT
 *
 *  @param localDateString <#localDateString description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)hTTPRequestGMTDateString;

/**
 *
     将GMT格式(格林威治标准时间)
     IN:周五, 17 07 2015 08:01:40 GMT
     
     转成本地的时间字符串
     OUT: 2015-07-17 16:01:40
 *
 */

+ (NSString *)localDateStringWithGMTDateFormatString:(NSString *)GMTDateFormateString;

/*
 * 距今第几个工作日的字符串
 */
+ (NSString*)workDayDistance:(NSUInteger)distance dateStringWithCurrentLocalDateString:(NSString *)currentLocalDateString;


/**
 *  将某种fromFormatterString 的字符串 转换成 formatterString 格式的时间字符串
 *
 *  @param dateString          需要转换的时间字符串
 *  @param fromFormatterString 旧有的时间格式
 *  @param toFormatterString   新的的时间格式
 *
 *  @return   toFormatterString格式下的字符串
 */
+ (NSString *)stringWithDateString:(NSString *)dateString fromFormatter:(NSString *)fromFormatterString Formatter:(NSString *)toFormatterString;


+ (NSString *) stringWithOriginDate:(NSDate *)originDate toFormatterString:(NSString *)toFormatterString;



@end
