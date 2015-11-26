//
//  JTHorizontalCalendar.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>
#import "JTCalendarManager.h"

#import "JTContent.h"
@protocol RefreshMonth <NSObject>
-(void)getNextMonthDataFrom:(NSDate*)currentdate;
-(void)getPreviousDataFrom:(NSDate*)currentdate;
-(void)selectDateInPreviouspage:(NSDate*)currentdate;
-(void)selectDateInNextpage:(NSDate*)currentdate;

@end

@interface JTHorizontalCalendarView : UIScrollView<JTContent>

@property (nonatomic, weak) JTCalendarManager *manager;

@property (nonatomic) NSDate *date;
@property (nonatomic,strong) NSDate *nextDate;
@property (nonatomic, weak) id<RefreshMonth> refDelegate;
@property (nonatomic) BOOL isReload;
@property(nonatomic, strong) UIView<JTCalendarPage> *centerView;


/*!
 * Must be call if override the class
 */
- (void)commonInit;
@end
