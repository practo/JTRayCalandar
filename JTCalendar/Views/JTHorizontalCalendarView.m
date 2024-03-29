//
//  JTHorizontalCalendar.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTHorizontalCalendarView.h"

#import "JTCalendarManager.h"

typedef NS_ENUM(NSInteger, JTCalendarPageMode) {
    JTCalendarPageModeFull,
    JTCalendarPageModeCenter,
    JTCalendarPageModeCenterLeft,
    JTCalendarPageModeCenterRight
};

@interface JTHorizontalCalendarView (){
    CGSize _lastSize;
    
    UIView<JTCalendarPage> *_leftView;
    UIView<JTCalendarPage> *_centerView;
    UIView<JTCalendarPage> *_rightView;
    
    NSDate *previousDate;
    JTCalendarPageMode _pageMode;
}

@end

@implementation JTHorizontalCalendarView
@synthesize nextDate;
@synthesize isReload;
@synthesize centerView = _centerView;
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

- (void)addDotforDate:(NSDate*)date
{
    
    _centerView.date = date;
    _rightView.date  =  date;
    _leftView.date = date;
    
    [_leftView reload];
    [_centerView reload];
    [_rightView reload];
    
}


- (void)commonInit
{
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.clipsToBounds = YES;
    previousDate = [NSDate date];
}

- (void)layoutSubviews
{
    [self resizeViewsIfWidthChanged];
    [self viewDidScroll];
}

- (void)resizeViewsIfWidthChanged
{
    CGSize size = self.frame.size;
    if(size.width != _lastSize.width){
        _lastSize = size;
        
        [self repositionViews];
    }
    else if(size.height != _lastSize.height){
        _lastSize = size;
        
        _leftView.frame = CGRectMake(_leftView.frame.origin.x, 0, size.width, size.height);
        _centerView.frame = CGRectMake(_centerView.frame.origin.x, 0, size.width, size.height);
        _rightView.frame = CGRectMake(_rightView.frame.origin.x, 0, size.width, size.height);
        
        self.contentSize = CGSizeMake(self.contentSize.width, size.height);
    }
}

- (void)viewDidScroll
{
    if(self.contentSize.width <= 0){
        return;
    }

    CGSize size = self.frame.size;
    
    switch (_pageMode) {
        case JTCalendarPageModeFull:
            
            if(self.contentOffset.x < size.width / 2.){
                [self loadPreviousPage];
            }
            else if(self.contentOffset.x > size.width * 1.5){
                [self loadNextPage];
            }
            
            break;
        case JTCalendarPageModeCenter:
            
            break;
        case JTCalendarPageModeCenterLeft:
            
            if(self.contentOffset.x < size.width / 2.){
                [self loadPreviousPage];
            }
            
            break;
        case JTCalendarPageModeCenterRight:
            
            if(self.contentOffset.x > size.width / 2.){
                [self loadNextPage];
            }
            
            break;
    }
    [_centerView setColorWeekDay];
    [_manager.scrollManager updateMenuContentOffset:(self.contentOffset.x / self.contentSize.width) pageMode:_pageMode];
}

- (void)loadPreviousPageWithAnimation
{
    switch (_pageMode) {
        case JTCalendarPageModeCenterRight:
        case JTCalendarPageModeCenter:
            return;
        default:
            break;
    }
    
    CGSize size = self.frame.size;
    CGPoint point = CGPointMake(self.contentOffset.x - size.width, 0);
    [self setContentOffset:point animated:YES];
}

- (void)loadNextPageWithAnimation
{
    switch (_pageMode) {
        case JTCalendarPageModeCenterLeft:
        case JTCalendarPageModeCenter:
            return;
        default:
            break;
    }
    
    CGSize size = self.frame.size;
    CGPoint point = CGPointMake(self.contentOffset.x + size.width, 0);
    [self setContentOffset:point animated:YES];
}
-(NSInteger)findDifferenceBetweenMonthsFromDate:(NSDate *)currentdate toDate:(NSDate *)prevDate
{
    NSDateComponents * currentDateComponents = [_manager.dateHelper.calendar components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate:currentdate];
    NSInteger currentMonth =currentDateComponents.month;
    NSLog(@"month number = %ld", (long)currentDateComponents.month);
    
    NSDateComponents * prevDateComponents = [_manager.dateHelper.calendar components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate:prevDate];
    NSInteger prevMonth =prevDateComponents.month;
    if (currentMonth>prevMonth)
        return (currentMonth-prevMonth);
    else
        return (prevMonth-currentMonth);
    
    
}

- (void)loadPreviousPage
{
    
    [_refDelegate selectDateInPreviouspage:_leftView.date];


    NSInteger monthsDiff = [self findDifferenceBetweenMonthsFromDate:_rightView.date toDate:previousDate];

    nextDate = [_manager.delegateManager dateForPreviousPageWithCurrentDate:_leftView.date];
    previousDate =_leftView.date;
    
    if (monthsDiff>0) {
        [_refDelegate getPreviousDataFrom:_leftView.date];
        
    }
    
    // Must be set before chaging date for PageView for updating day views
    self->_date = _leftView.date;
    
    UIView<JTCalendarPage> *tmpView = _rightView;
    
    _rightView = _centerView;
    _centerView = _leftView;
    
    _leftView = tmpView;
    _leftView.date = nextDate;
    [_leftView setColorWeekDay];
    [self updateMenuDates];
    
    JTCalendarPageMode previousPageMode = _pageMode;
    
    [self updatePageMode];
    
    CGSize size = self.frame.size;
    
    switch (_pageMode) {
        case JTCalendarPageModeFull:
            
            _leftView.frame = CGRectMake(0, 0, size.width, size.height);
            _centerView.frame = CGRectMake(size.width, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width * 2, 0, size.width, size.height);
            
            if(previousPageMode == JTCalendarPageModeFull){
                self.contentOffset = CGPointMake(self.contentOffset.x + size.width, 0);
            }
            else if(previousPageMode ==  JTCalendarPageModeCenterLeft){
                self.contentOffset = CGPointMake(self.contentOffset.x + size.width, 0);
            }
            
            self.contentSize = CGSizeMake(size.width * 3, size.height);
            
            break;
        case JTCalendarPageModeCenter:
            // Not tested
            
            _leftView.frame = CGRectMake(- size.width, 0, size.width, size.height);
            _centerView.frame = CGRectMake(0, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width, 0, size.width, size.height);
            
            self.contentSize = size;
            
            break;
        case JTCalendarPageModeCenterLeft:
            
            _leftView.frame = CGRectMake(0, 0, size.width, size.height);
            _centerView.frame = CGRectMake(size.width, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width * 2, 0, size.width, size.height);
            
            self.contentOffset = CGPointMake(self.contentOffset.x + size.width, 0);
            self.contentSize = CGSizeMake(size.width * 2, size.height);
            
            break;
        case JTCalendarPageModeCenterRight:
            
            _leftView.frame = CGRectMake(- size.width, 0, size.width, size.height);
            _centerView.frame = CGRectMake(0, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width, 0, size.width, size.height);
            
            self.contentSize = CGSizeMake(size.width * 2, size.height);
            
            break;
    }
    
    // Update dayViews becuase current month changed
    [_rightView reload];
    [_centerView reload];
    
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendarDidLoadPreviousPage:)]){
        [_manager.delegate calendarDidLoadPreviousPage:_manager];
    }
    
   
   

}

- (void)loadNextPage
{
    [_refDelegate selectDateInNextpage:_rightView.date];
    NSInteger monthsDiff = [self findDifferenceBetweenMonthsFromDate:_rightView.date toDate:previousDate];
    
    nextDate = [_manager.delegateManager dateForNextPageWithCurrentDate:_rightView.date];
    previousDate = _rightView.date;
    if (monthsDiff>0) {
        [_refDelegate getNextMonthDataFrom:_rightView.date];
        
    }
    
    // Must be set before chaging date for PageView for updating day views
    self->_date = _rightView.date;
    
    UIView<JTCalendarPage> *tmpView = _leftView;
    
    _leftView = _centerView;
    _centerView = _rightView;
    
    _rightView = tmpView;
    _rightView.date = nextDate;
     [_rightView setColorWeekDay];
    [self updateMenuDates];
    
    JTCalendarPageMode previousPageMode = _pageMode;
    
    [self updatePageMode];
    
    CGSize size = self.frame.size;
    
    switch (_pageMode) {
        case JTCalendarPageModeFull:
            
            _leftView.frame = CGRectMake(0, 0, size.width, size.height);
            _centerView.frame = CGRectMake(size.width, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width * 2, 0, size.width, size.height);
            
            if(previousPageMode == JTCalendarPageModeFull){
                self.contentOffset = CGPointMake(self.contentOffset.x - size.width, 0);
            }
            self.contentSize = CGSizeMake(size.width * 3, size.height);
            
            break;
        case JTCalendarPageModeCenter:
            // Not tested
            
            _leftView.frame = CGRectMake(- size.width, 0, size.width, size.height);
            _centerView.frame = CGRectMake(0, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width, 0, size.width, size.height);
            
            self.contentSize = size;
            
            break;
        case JTCalendarPageModeCenterLeft:
            
            _leftView.frame = CGRectMake(0, 0, size.width, size.height);
            _centerView.frame = CGRectMake(size.width, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width * 2, 0, size.width, size.height);

            if(previousPageMode != JTCalendarPageModeCenterRight){
                self.contentOffset = CGPointMake(self.contentOffset.x - size.width, 0);
            }

            // Must be set a the end else the scroll freeze
            self.contentSize = CGSizeMake(size.width * 2, size.height);

            break;
        case JTCalendarPageModeCenterRight:
            // Not tested
            
            _leftView.frame = CGRectMake(- size.width, 0, size.width, size.height);
            _centerView.frame = CGRectMake(0, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width, 0, size.width, size.height);

            self.contentSize = CGSizeMake(size.width * 2, size.height);
            
            break;
    }
    
    // Update dayViews becuase current month changed
    [_leftView reload];
    [_centerView reload];
    
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendarDidLoadNextPage:)]){
        [_manager.delegate calendarDidLoadNextPage:_manager];
    }
}

- (void)setDate:(NSDate *)date
{
    NSAssert(date != nil, @"date cannot be nil");
    NSAssert(_manager != nil, @"manager cannot be nil");
    
    self->_date = date;
    
    if(!_leftView){
        _leftView = [_manager.delegateManager buildPageView];
        [self addSubview:_leftView];
        
        _centerView = [_manager.delegateManager buildPageView];
        [self addSubview:_centerView];
        
        _rightView = [_manager.delegateManager buildPageView];
        [self addSubview:_rightView];
        
        [self updateManagerForViews];
    }
    
    _leftView.date = [_manager.delegateManager dateForPreviousPageWithCurrentDate:date];
    _centerView.date = date;
    _rightView.date = [_manager.delegateManager dateForNextPageWithCurrentDate:date];
    if (self.isReload) {
        self.isReload = NO;
        [_centerView setColorForSelectedDay:[self.manager date]];
        
    }
    [self updateMenuDates];
    
    [self updatePageMode];
    [self repositionViews];
}

- (void)setManager:(JTCalendarManager *)manager
{
    self->_manager = manager;
    [self updateManagerForViews];
}

- (void)updateManagerForViews
{
    if(!_manager || !_leftView){
        return;
    }
    
    _leftView.manager = _manager;
    _centerView.manager = _manager;
    _rightView.manager = _manager;
}

- (void)updatePageMode
{
    BOOL haveLeftPage = [_manager.delegateManager canDisplayPageWithDate:_leftView.date];
    BOOL haveRightPage = [_manager.delegateManager canDisplayPageWithDate:_rightView.date];
    
    if(haveLeftPage && haveRightPage){
        _pageMode = JTCalendarPageModeFull;
    }
    else if(!haveLeftPage && !haveRightPage){
        _pageMode = JTCalendarPageModeCenter;
    }
    else if(!haveLeftPage){
        _pageMode = JTCalendarPageModeCenterRight;
    }
    else{
        _pageMode = JTCalendarPageModeCenterLeft;
    }
    
    if(_manager.settings.pageViewHideWhenPossible){
        _leftView.hidden = !haveLeftPage;
        _rightView.hidden = !haveRightPage;
    }
    else{
        _leftView.hidden = NO;
        _rightView.hidden = NO;
    }
}

- (void)repositionViews
{
    CGSize size = self.frame.size;
    self.contentInset = UIEdgeInsetsZero;
    
    switch (_pageMode) {
        case JTCalendarPageModeFull:
            self.contentSize = CGSizeMake(size.width * 3, size.height);
            
            _leftView.frame = CGRectMake(0, 0, size.width, size.height);
            _centerView.frame = CGRectMake(size.width, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width * 2, 0, size.width, size.height);
            
            self.contentOffset = CGPointMake(size.width, 0);
            break;
        case JTCalendarPageModeCenter:
            self.contentSize = size;
            
            _leftView.frame = CGRectMake(- size.width, 0, size.width, size.height);
            _centerView.frame = CGRectMake(0, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width, 0, size.width, size.height);
            
            self.contentOffset = CGPointZero;
            break;
        case JTCalendarPageModeCenterLeft:
            self.contentSize = CGSizeMake(size.width * 2, size.height);
            
            _leftView.frame = CGRectMake(0, 0, size.width, size.height);
            _centerView.frame = CGRectMake(size.width, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width * 2, 0, size.width, size.height);
            
            self.contentOffset = CGPointMake(size.width, 0);
            break;
        case JTCalendarPageModeCenterRight:
            self.contentSize = CGSizeMake(size.width * 2, size.height);
            
            _leftView.frame = CGRectMake(- size.width, 0, size.width, size.height);
            _centerView.frame = CGRectMake(0, 0, size.width, size.height);
            _rightView.frame = CGRectMake(size.width, 0, size.width, size.height);
            
            self.contentOffset = CGPointZero;
            break;
    }
}

- (void)updateMenuDates
{
    [_manager.scrollManager setMenuPreviousDate:_leftView.date
                                    currentDate:_centerView.date
                                       nextDate:_rightView.date];
}

@end
