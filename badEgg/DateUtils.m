//
//  DateUtils.m
//  CONTACT_zhongyan
//
//  Created by user on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DateUtils.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@implementation DateUtils
//功能:时间转字符串
//参数:date
//参数:返回账户名的字符串
//备注:11/3 lilin 添加
+(NSString*)dateToString:(NSDate*)date DateFormat:(NSString*)format
{
    if (!date) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

//功能:字符串转时间
//参数:strDate format
//参数:返回账户名的字符串
//备注:11/3 lilin 添加
+(NSDate*)stringToDate:(NSString*)strDate DateFormat:(NSString*)format
{
    if (!strDate) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *dateFromString = [dateFormatter dateFromString:strDate];
    return dateFromString;
}

//功能:获取当前时间的函数
//参数:
//参数:返回账户名的字符串
//备注:11/3 lilin 添加
+ (NSString*)get_system_today_time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:(NSDateFormatterStyle)kCFDateFormatterMediumStyle];
    [formatter setTimeStyle:(NSDateFormatterStyle)kCFDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd-hh-mm-ss"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
    NSString *string_time = [formatter stringFromDate:date];
    
    NSArray *time = [string_time componentsSeparatedByString:@"-"];
    int value_year = [[time objectAtIndex:0]intValue];
    int value_month = [[time objectAtIndex:1]intValue];
    int value_day = [[time objectAtIndex:2]intValue];
    int value_hour = [[time objectAtIndex:3]intValue];
    int value_minute = [[time objectAtIndex:4]intValue];
    int value_second = [[time objectAtIndex:5]intValue];
    
    [formatter setDateFormat:@"EEEE"];
    NSString *week_day = [formatter stringFromDate:date];
    NSString *system_time = [[NSString alloc] initWithFormat:@"{\"year\":\"%d\",\"month\":\"%d\",\"day\":\"%d\",\"hour\":\"%d\",\"minute\":\"%d\",\"second\":\"%d\",\"week_day\":\"%@\"}",value_year,value_month,value_day,value_hour,value_minute,value_second,week_day];
    return system_time;
}


//功能:获取当前时间的函数
//参数:好友名
//参数:返回账户名的字符串
//备注:11/3 lilin 添加
+(NSString*)date
{
    NSDate* date = [NSDate date];//取得当天的日期变量
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps = [calendar components:(   NSYearCalendarUnit|NSMonthCalendarUnit|
                                                    NSDayCalendarUnit|NSHourCalendarUnit |
                                                    NSSecondCalendarUnit|NSMinuteCalendarUnit) 
                                          fromDate:date];
    
    NSString* now = [NSString stringWithFormat:@"%.4d-%.2d-%.2d %.2d:%.2d:%.2d",   [comps year],[comps month], 
                     [comps day],[comps hour],
                     [comps minute],[comps second]];
    return now;
}

//功能:获取当前时间的函数
//参数:好友名
//参数:返回账户名的字符串
//备注:11/3 lilin 添加
+(NSString*)curerntTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; 
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    return strDate;
}

//- (NSTimeInterval)timeIntervalSinceDate:(NSDate *)refDate;
//
//以refDate为基准时间，返回实例保存的时间与refDate的时间间隔

//- (NSTimeInterval)timeIntervalSinceNow;
//
//以当前时间(Now)为基准时间，返回实例保存的时间与当前时间(Now)的时间间隔

+(BOOL)isSameWeekWithDate:(NSDate*)src  Compare:(NSDate*)dest
{
    return YES;
}
@end

@implementation NSDate (Utilities)
+(NSString*)curerntTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    return strDate;
}
#pragma mark Relative Dates

+ (NSDate *) dateWithDaysFromNow: (NSUInteger) days
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_DAY * days;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;	
}

+ (NSDate *) dateWithDaysBeforeNow: (NSUInteger) days
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_DAY * days;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;	
}

+ (NSDate *) dateTomorrow
{
	return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
	return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateWithHoursFromNow: (NSUInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;	
}

+ (NSDate *) dateWithHoursBeforeNow: (NSUInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;	
}

+ (NSDate *) dateWithMinutesFromNow: (NSUInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;		
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSUInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;		
}

+(NSDate *) dateWithString:(NSString*)string
{
    if (!string) return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateTimeFormat];
    return [dateFormatter dateFromString:string];
}
#pragma mark Comparing Dates

- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	return (([components1 year] == [components2 year]) &&
			([components1 month] == [components2 month]) && 
			([components1 day] == [components2 day]));
}

- (BOOL) isToday
{
	return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) isTomorrow
{
	return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL) isYesterday
{
	return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{    
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	
	// Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
	if ([components1 week] != [components2 week]) return NO;
	
	// Must have a time interval under 1 week. Thanks @aclark
	return (abs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) isThisWeek
{
	return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameYearAsDate:newDate];
}

- (BOOL) isLastWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameYearAsDate:newDate];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
	return ([components1 year] == [components2 year]);
}

- (BOOL) isThisYear
{
	return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return ([components1 year] == ([components2 year] + 1));
}

- (BOOL) isLastYear
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return ([components1 year] == ([components2 year] - 1));
}

- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
	return ([self earlierDate:aDate] == self);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
	return ([self laterDate:aDate] == self);
}


#pragma mark Adjusting Dates

- (NSDate *) dateByAddingDays: (NSInteger)dDays
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;		
}

- (NSDate *) dateBySubtractingDays: (NSInteger)dDays
{
	return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *) dateByAddingHours: (NSUInteger) dHours
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;		
}

- (NSDate *) dateBySubtractingHours: (NSUInteger) dHours
{
	return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *) dateByAddingMinutes: (NSUInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;			
}

- (NSDate *) dateBySubtractingMinutes: (NSUInteger) dMinutes
{
	return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDate *) dateAtStartOfDay
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate
{
	NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
	return dTime;
}

#pragma mark Retrieving Intervals
- (NSInteger) secondsAfterDate: (NSDate *) date
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval1 = [zone secondsFromGMTForDate: self];
    NSDate* resultdate = [self  dateByAddingTimeInterval:interval1];
    NSInteger interval2 = [zone secondsFromGMTForDate: date];
    date = [date  dateByAddingTimeInterval: interval2];
    
	return [resultdate timeIntervalSinceDate:date];
}

- (NSInteger) secondsBeforeDate: (NSDate *) aDate
{
    return [aDate timeIntervalSinceDate:self];
}

- (NSInteger) minutesAfterDate: (NSDate *) date
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval1 = [zone secondsFromGMTForDate: self];
    NSDate* resultdate  = [self  dateByAddingTimeInterval: interval1]; 
    NSInteger interval2 = [zone secondsFromGMTForDate: date];
    date = [date  dateByAddingTimeInterval: interval2];     
	NSTimeInterval ti = [resultdate timeIntervalSinceDate:date];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
    NSString* nowstr = [DateUtils dateToString:self DateFormat:sdateFormat];
    NSString* datestr = [DateUtils dateToString:aDate DateFormat:sdateFormat];
    
    NSDate* now = [DateUtils stringToDate:nowstr DateFormat:sdateFormat];
    NSDate* date = [DateUtils stringToDate:datestr DateFormat:sdateFormat];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval1 = [zone secondsFromGMTForDate: now];
    now = [now  dateByAddingTimeInterval: interval1]; 
    
    NSInteger interval2 = [zone secondsFromGMTForDate: date];
    date = [date  dateByAddingTimeInterval: interval2]; 
    
	NSTimeInterval ti = [now timeIntervalSinceDate:date];
	return (NSInteger) (ti / D_DAY);
}

-(NSString*)dateToDetail
{
    NSDate *now = [NSDate date];
    int timeRange = [now daysAfterDate:self];
    NSString* datestr = [DateUtils dateToString:self DateFormat:@"yy-MM-dd"];
    if ([self isSameWeekAsDate:now] && timeRange == 0) {
        return @"今天";
    }else if([self isSameWeekAsDate:now] && timeRange == 1 && self.weekday < now.weekday){
        return @"昨天";
    }else if([self isSameWeekAsDate:now] && timeRange > 1 && self.weekday < now.weekday){
        return [NSDate numberToWeek:self.weekday];
    }else if((![self isSameWeekAsDate:now] && timeRange < now.weekday + 7)  || ([self isSameWeekAsDate:now] && self.weekday == 7 && timeRange >0)){
        //上周
        return datestr;
    }else if(![self isSameWeekAsDate:now] && timeRange > now.weekday + 7 && timeRange < now.weekday + 14){
         //两周前
        return datestr;
    }else if(![self isSameWeekAsDate:now] && timeRange > now.weekday + 14){
        //更早
        return datestr;
    }else{
        return datestr;
        return nil;
    } 
    
}


- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_DAY);
}

#pragma mark Decomposing Dates

- (NSInteger) nearestHour
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	NSDateComponents *components = [CURRENT_CALENDAR components:NSHourCalendarUnit fromDate:newDate];
	return [components hour];
}

- (NSInteger) hour
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components hour];
}

- (NSInteger) minute
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components minute];
}

- (NSInteger) seconds
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components second];
}

- (NSInteger) day
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components day];
}

- (NSInteger) month
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components month];
}

- (NSInteger) week
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components week];
}

- (NSInteger) weekday
{
	//NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	//return [components weekday];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    NSString* weekday = [formatter stringFromDate:self]; 
    if ([weekday isEqualToString:@"Monday"] || [weekday isEqualToString:@"星期一"])            return 1;
    else if([weekday isEqualToString:@"Tuesday"]   || [weekday isEqualToString:@"星期二"])     return 2;
    else if([weekday isEqualToString:@"Wednesday"] || [weekday isEqualToString:@"星期三"])     return 3;
    else if([weekday isEqualToString:@"Thursday"]  || [weekday isEqualToString:@"星期四"])     return 4;
    else if([weekday isEqualToString:@"Friday"]    || [weekday isEqualToString:@"星期五"])     return 5;
    else if([weekday isEqualToString:@"Saturday"]  || [weekday isEqualToString:@"星期六"])     return 6;
    else if([weekday isEqualToString:@"Sunday"]    || [weekday isEqualToString:@"星期日"])     return 0;
    else return -1;
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components weekdayOrdinal];
}
- (NSInteger) year
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components year];
}

+(NSString*)numberToWeek:(NSInteger)weekNumber
{
    switch (weekNumber) {
        case 1:
            return @"星期一";
            break;
        case 2:
            return @"星期二";
            break;
        case 3:
            return @"星期三";
            break;      
        case 4:
            return @"星期四";
            break;
        case 5:
            return @"星期五";
            break;
        case 6:
            return @"星期六";
            break;
        case 0:
            return @"星期日";
            break;
        default:
            return nil;
            break;
    }
}

+(NSInteger)weekToNumber:(NSString*)weekString
{
    if ([weekString isEqualToString:@"星期一"])return 1;
    else if([weekString isEqualToString:@"星期二"]) return 2;
    else if([weekString isEqualToString:@"星期三"]) return 3;
    else if([weekString isEqualToString:@"星期四"]) return 4;
    else if([weekString isEqualToString:@"星期五"]) return 5;
    else if([weekString isEqualToString:@"星期六"]) return 6;
    else if([weekString isEqualToString:@"星期日"]) return 7;
    else return -1;
}

-(NSString *)LunarForSolar
{
    //天干名称
    NSArray *cTianGan = [NSArray arrayWithObjects:@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸", nil];
    
    //地支名称
    NSArray *cDiZhi = [NSArray arrayWithObjects:@"子",@"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥",nil];
    
    //属相名称
    NSArray *cShuXiang = [NSArray arrayWithObjects:@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊",@"猴",@"鸡",@"狗",@"猪",nil];
    
    //农历日期名
    NSArray *cDayName = [NSArray arrayWithObjects:@"*",@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",
                         @"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",
                         @"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十",nil];
    
    //农历月份名
    NSArray *cMonName = [NSArray arrayWithObjects:@"*",@"正",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"腊",nil];
    
    //公历每月前面的天数
    const int wMonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};
    
    //农历数据
    const int wNongliData[100] = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438
        ,3402,3749,331177,1453,694,201326,2350,465197,3221,3402
        ,400202,2901,1386,267611,605,2349,137515,2709,464533,1738
        ,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762
        ,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413
        ,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395
        ,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031
        ,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222
        ,268949,3402,3493,133973,1386,464219,605,2349,334123,2709
        ,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877};
    
    static int wCurYear,wCurMonth,wCurDay;
    static int nTheDate,nIsEnd,m,k,n,i,nBit;
    
    //取当前公历年、月、日
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit |NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self];
    wCurYear = [components year];
    wCurMonth = [components month];
    wCurDay = [components day];
    
    //计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth - 1] - 38;
    if((!(wCurYear % 4)) && (wCurMonth > 2))
        nTheDate = nTheDate + 1;
    
    //计算农历天干、地支、月、日
    nIsEnd = 0;
    m = 0;
    while(nIsEnd != 1)
    {
        if(wNongliData[m] < 4095)
            k = 11;
        else
            k = 12;
        n = k;
        while(n>=0)
        {
            //获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m];
            for(i=1;i<n+1;i++)
                nBit = nBit/2;
            
            nBit = nBit % 2;
            
            if (nTheDate <= (29 + nBit))
            {
                nIsEnd = 1;
                break;
            }
            
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        }
        if(nIsEnd)
            break;
        m = m + 1;
    }
    wCurYear = 1921 + m;
    wCurMonth = k - n + 1;
    wCurDay = nTheDate;
    if (k == 12)
    {
        if (wCurMonth == wNongliData[m] / 65536 + 1)
            wCurMonth = 1 - wCurMonth;
        else if (wCurMonth > wNongliData[m] / 65536 + 1)
            wCurMonth = wCurMonth - 1;
    }
    
    //生成农历天干、地支、属相
    NSString *szShuXiang = (NSString *)[cShuXiang objectAtIndex:((wCurYear - 4) % 60) % 12];
    NSString *szNongli = [NSString stringWithFormat:@"%@(%@%@)年",szShuXiang, (NSString *)[cTianGan objectAtIndex:((wCurYear - 4) % 60) % 10],(NSString *)[cDiZhi objectAtIndex:((wCurYear - 4) % 60) %12]];
    
    //生成农历月、日
    NSString *szNongliDay;
    if (wCurMonth < 1){
        szNongliDay = [NSString stringWithFormat:@"闰%@",(NSString *)[cMonName objectAtIndex:-1 * wCurMonth]]; 
    }
    else{
        szNongliDay = (NSString *)[cMonName objectAtIndex:wCurMonth]; 
    }
    
    NSString *lunarDate = [NSString stringWithFormat:@"%@ %@月 %@",szNongli,szNongliDay,(NSString*)[cDayName objectAtIndex:wCurDay]];
    
    return lunarDate;
}
@end
