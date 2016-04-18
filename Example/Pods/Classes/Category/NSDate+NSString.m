/*
 G: 公元时代，例如AD公元
 yy: 年的后2位
 yyyy: 完整年
 MM: 月，显示为1-12
 MMM: 月，显示为英文月份简写,如 Jan
 MMMM: 月，显示为英文月份全称，如 Janualy
 dd: 日，2位数表示，如02
 d: 日，1-2位显示，如 2
 EEE: 简写星期几，如Sun
 EEEE: 全写星期几，如Sunday
 aa: 上下午，AM/PM
 H: 时，24小时制，0-23
 K：时，12小时制，0-11
 m: 分，1-2位
 mm: 分，2位
 s: 秒，1-2位
 ss: 秒，2位
 S: 毫秒
 Z：GMT
 
 
 yyyy-MM-dd HH:mm:ss.SSS
 yyyy-MM-dd HH:mm:ss
 yyyy-MM-dd
 MM dd yyyy
 */

#import "NSDate+NSString.h"
#import <objc/runtime.h>
#define CPDeadlineDateShowFormatter @"yyyy-MM-dd EEE"
@implementation NSDate (NSString)

static char DATEFORMATTERKEY;
+ (NSString *)dateWithFormatterString:(NSString *)formatterString {
    
    NSDateFormatter *dateFormatter = objc_getAssociatedObject(self, &DATEFORMATTERKEY);
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        objc_setAssociatedObject(self, &DATEFORMATTERKEY, dateFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if (!formatterString.length) {
        dateFormatter.dateFormat = @"yyyyMMddHHmmss";
        
    }else dateFormatter.dateFormat = formatterString;
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)GMTDateFormatStringWithLocalDateString:(NSString *)localDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (!localDateString) {
        localDateString = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    NSDate *dateFormatted = [dateFormatter dateFromString:localDateString];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setTimeZone:timeZone];
    
    //输出格式
    [dateFormatter setDateFormat:@"EEE, dd MM yyyy HH:mm:ss zzz"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

+ (NSString *)hTTPRequestGMTDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//[formatter setDateFormat:@"ccc',' d MMM yyyy H:m:s 'GMT'"];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setTimeZone:timeZone];
    
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"us"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}


+ (NSString *)localDateStringWithGMTDateFormatString:(NSString *)GMTDateFormateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MM yyyy HH:mm:ss zzz"];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:GMTDateFormateString];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    
    return dateString;
}

+ (NSString*)workDayDistance:(NSUInteger)distance dateStringWithCurrentLocalDateString:(NSString *)currentLocalDateString
{
    NSDateFormatter *dateFormatter = objc_getAssociatedObject(self, &DATEFORMATTERKEY);
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        objc_setAssociatedObject(self, &DATEFORMATTERKEY, dateFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    dateFormatter.dateFormat = CPDeadlineDateShowFormatter;
    //1、当当前的日期格式 转换成Date
    NSDate *currenDate = [dateFormatter dateFromString:currentLocalDateString];
    
    //2、通过NSCalendar 计算出下一个工作日Date
    NSDate *nextWorkDayDate = [self nextWorkDayWithCurrentDate:currenDate distance:distance];
    
    //3、设定输出DateFormat的 时间字符串格式
    dateFormatter.dateFormat = @"MM-dd EEEE";
    
    //4、将下一个工作日Date 转换成一个格式 的nextWorkDayDateString
    NSString *nextWorkDayDateString = [dateFormatter stringFromDate:nextWorkDayDate];
    return nextWorkDayDateString;
}


+ (NSDate *)nextWorkDayWithCurrentDate:(NSDate *)currenDate distance:(NSUInteger)distance{
    if (distance == 0)return currenDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday;
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:currenDate];
    switch ([comps weekday]) {
            /*周日为1，周一为2，周二为3，周三为4，周四为5，周五为6，周六为7*/
        case 7://周六
            comps.day += 2;
            break;
        case 6://周五
            comps.day += 3;
            break;
        default:
            comps.day += 1;
            break;
    }
    NSDate *nextWorkDate = [calendar dateFromComponents:comps];
    distance -= 1;
    nextWorkDate = [self nextWorkDayWithCurrentDate:nextWorkDate distance:distance];
    return nextWorkDate;
}


//static char DateFormatterKey;
+ (NSString *)stringWithDateString:(NSString *)originDateString fromFormatter:(NSString *)fromFormatterString Formatter:(NSString *)toFormatterString {
    
    NSDateFormatter* formatter = objc_getAssociatedObject(self, &DATEFORMATTERKEY);
    
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        objc_setAssociatedObject(self, &DATEFORMATTERKEY, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    formatter.dateFormat = fromFormatterString;
    if (!fromFormatterString.length) {
        formatter.dateFormat = @"yyyyMMddHHmmss";
    }
    
    NSDate* fromDate = [formatter dateFromString:originDateString];
    
    return [self stringWithOriginDate:fromDate toFormatterString:toFormatterString];
}

+ (NSString *) stringWithOriginDate:(NSDate *)originDate toFormatterString:(NSString *)toFormatterString {
    NSDateFormatter* formatter = objc_getAssociatedObject(self, &DATEFORMATTERKEY);
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        objc_setAssociatedObject(self, &DATEFORMATTERKEY, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if (!toFormatterString.length) {
        formatter.dateFormat = @"yyyyMMddHHmmss";
        
    }else formatter.dateFormat = toFormatterString;
    
    return [formatter stringFromDate:originDate];
}

@end
