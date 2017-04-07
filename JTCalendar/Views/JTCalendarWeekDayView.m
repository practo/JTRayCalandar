//
//  JTCalendarWeekDayView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarWeekDayView.h"

#import "JTCalendarManager.h"

#define NUMBER_OF_DAY_BY_WEEK 7.

@implementation JTCalendarWeekDayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    NSMutableArray *dayViews = [NSMutableArray new];
    
    for(int i = 0; i < NUMBER_OF_DAY_BY_WEEK; ++i){
        UILabel *label = [UILabel new];
        [self addSubview:label];
        [dayViews addObject:label];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:10];
    }
    
    _dayViews = dayViews;
}

- (void)reload
{
    NSAssert(_manager != nil, @"manager cannot be nil");
    
    NSDateFormatter *dateFormatter = [_manager.dateHelper createDateFormatter];
    NSMutableArray *days = nil;
    
    dateFormatter.timeZone = _manager.dateHelper.calendar.timeZone;
    dateFormatter.locale = _manager.dateHelper.calendar.locale;
    
    switch(_manager.settings.weekDayFormat) {
        case JTCalendarWeekDayFormatSingle:
            days = [[dateFormatter veryShortStandaloneWeekdaySymbols] mutableCopy];
            break;
        case JTCalendarWeekDayFormatShort:
            days = [[dateFormatter shortStandaloneWeekdaySymbols] mutableCopy];
            break;
        case JTCalendarWeekDayFormatFull:
            days = [[dateFormatter standaloneWeekdaySymbols] mutableCopy];
            break;
    }
    
    for(NSInteger i = 0; i < days.count; ++i){
        NSString *day = days[i];
        [days replaceObjectAtIndex:i withObject:[day uppercaseString]];
    }
    
    // Redorder days for be conform to calendar
    {
        NSCalendar *calendar = [_manager.dateHelper calendar];
        NSUInteger firstWeekday = (calendar.firstWeekday + 6) % 7; // Sunday == 1, Saturday == 7
        
        for(int i = 0; i < firstWeekday; ++i){
            id day = [days firstObject];
            [days removeObjectAtIndex:0];
            [days addObject:day];
        }
    }
    
    for(int i = 0; i < NUMBER_OF_DAY_BY_WEEK; ++i){
        UILabel *label =  _dayViews[i];
        label.text = [days[i] capitalizedString];
    }
}
- (void)selectedDay:(NSInteger )selectedWeekDay
{
    
    for(int i = 0; i < NUMBER_OF_DAY_BY_WEEK; ++i){
        UILabel *label =  _dayViews[i];
        [_manager.delegateManager calendarWeekDayView:label isSelectedDay:NO];
    }
    
    if (selectedWeekDay > [_dayViews count]) {
        return;
    }
    UILabel *label = _dayViews[selectedWeekDay];
    // Singularity Calendar Color
    [_manager.delegateManager calendarWeekDayView:label isSelectedDay:YES];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(!_dayViews){
        return;
    }
    
    CGFloat x = 0;
    CGFloat dayWidth = self.frame.size.width / NUMBER_OF_DAY_BY_WEEK;
    CGFloat dayHeight = self.frame.size.height;
    
    for(UIView *dayView in _dayViews){
        dayView.frame = CGRectMake(x, -8, dayWidth, dayHeight);
        x += dayWidth;
    }
}

@end
