//
//  ViewController.m
//  MonthPicker
//
//  Created by Denis Chaschin on 07.11.14.
//  Copyright (c) 2014 diniska. All rights reserved.
//

#import "ViewController.h"
#import "MAKMonthPicker.h"

static const NSTimeInterval ktTimeInMonth = 60 * 60 * 24 * 31;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MAKMonthPicker *monthPicker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.monthPicker.format =  MAKMonthPickerFormatMonth | MAKMonthPickerFormatYear;
    self.monthPicker.monthFormat = @"%n |%c";
    self.monthPicker.date = [NSDate dateWithTimeIntervalSinceNow:-ktTimeInMonth];
    self.monthPicker.yearRange = NSMakeRange(2000, 100);
}
@end
