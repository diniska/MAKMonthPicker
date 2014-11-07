//
//  MAKMonthPicker.m
//  MonthPicker
//
//  Created by Denis Chaschin on 07.11.14.
//  Copyright (c) 2014 diniska. All rights reserved.
//

#import "MAKMonthPicker.h"

static inline void getCurrentYearAndMonth(NSInteger *year, NSInteger *month, NSDate *date) {
    NSCalendar *const calendar = [NSCalendar currentCalendar];
    [calendar getEra:nil year:year month:month day:nil fromDate:date];
}

static inline BOOL isBitMaskEnabled(NSInteger value, NSInteger mask) {
    return value & mask;
}

static inline BOOL isMonthComponentEnabled(NSInteger value) {
    return isBitMaskEnabled(value, MAKMonthPickerFormatMonth);
}

static inline BOOL isYearComponentEnabled(NSInteger value) {
    return isBitMaskEnabled(value, MAKMonthPickerFormatYear);
}

static NSString *const kMonthCodeFormat = @"%c";
static NSString *const kMonthNameFormat = @"%n";
static const NSInteger kDefaultYearOffsets = 10;
static const NSInteger kNumberOfMonthsInYear =  12;

@implementation MAKMonthPicker {
    NSInteger _numberOfComponents;
    NSInteger _numberOfRowsInComponent[2];
    NSDateFormatter *_dateFormatter;//To receive localized month name
    NSInteger _selectedMonth;
    NSInteger _selectedYear;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _format = MAKMonthPickerFormatMonth | MAKMonthPickerFormatYear;
    NSInteger year, month;
    getCurrentYearAndMonth(&year, &month, [NSDate date]);
    _yearRange = NSMakeRange(year - kDefaultYearOffsets, kDefaultYearOffsets + kDefaultYearOffsets);
    _numberOfRowsInComponent[0] = kNumberOfMonthsInYear;
    _numberOfRowsInComponent[1] = _yearRange.length;
    _dateFormatter = [[NSDateFormatter alloc] init];
    _monthFormat = [NSString stringWithFormat:@"%@ %@", kMonthNameFormat, kMonthCodeFormat];
    _selectedMonth = month;
    _selectedYear = year;
    self.dataSource = self;
    self.delegate = self;
    
    //select current date
    [self updateSelectedDateAnimated:NO];
}

#pragma mark - Getters
- (NSDate *)date {
    NSDateComponents *const components = [[NSDateComponents alloc] init];
    components.month = _selectedMonth;
    components.year = _selectedMonth;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

#pragma mark - Setters
- (void)setDate:(NSDate *)date animated:(BOOL)animated {
    getCurrentYearAndMonth(&_selectedYear, &_selectedMonth, date);
    [self updateSelectedDateAnimated:animated];
}

- (void)setDate:(NSDate *)date {
    [self setDate:date animated:NO];
}

- (void)setMonthFormat:(NSString *)monthFormat {
    if ([_monthFormat isEqual:monthFormat]) {
        return;
    }
    
    _monthFormat = monthFormat;
    if (isMonthComponentEnabled(self.format)) {
        [self reloadComponent:0];
    }
}

- (void)setFormat:(MAKMonthPickerFormat)format {
    if (format == _format) {
        return;
    }
    
    _format = format;
    switch (format) {
        case MAKMonthPickerFormatMonth:
            _numberOfRowsInComponent[0] = kNumberOfMonthsInYear;
            _numberOfComponents = 1;
            break;
        case MAKMonthPickerFormatYear:
            _numberOfRowsInComponent[0] = _yearRange.length;
            _numberOfComponents = 1;
            break;
        default:
            _numberOfRowsInComponent[0] = kNumberOfMonthsInYear;
            _numberOfRowsInComponent[1] = _yearRange.length;
            _numberOfComponents = 2;
            break;
    }
    [self reloadAllComponents];
    [self updateSelectedDateAnimated:NO];
}

- (void)setYearRange:(NSRange)yearRange {
    _yearRange = yearRange;
    const BOOL needToUpdateYearValue = NSLocationInRange(_selectedYear, yearRange);
    if (isMonthComponentEnabled(self.format)) {
        if (isYearComponentEnabled(self.format)) {
            [self reloadComponent:1];
            if (needToUpdateYearValue) {
                [self selectRow:_selectedYear - _yearRange.location inComponent:1 animated:NO];
            }
        }
    } else if (isYearComponentEnabled(self.format)) {
        [self reloadComponent:0];
        if (needToUpdateYearValue) {
            [self selectRow:_selectedYear - _yearRange.location inComponent:1 animated:NO];
        }
    }
}

#pragma mark - <UIPickerViewDataSource>
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return isMonthComponentEnabled(self.format) + isYearComponentEnabled(self.format);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _numberOfRowsInComponent[component];
}

#pragma mark - <UIPickerViewDelegate>
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0 && isMonthComponentEnabled(self.format)) {
        return [self titleForMonthAtRow:row];
    }
    return [self titleForYearAtRow:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0 && isMonthComponentEnabled(self.format)) {
        _selectedMonth = row + 1;
    } else {
        _selectedYear = _yearRange.location + row;
    }
    [self.monthPickerDelegate monthPickerDidChangeDate:self];
}

#pragma mark - Private
- (NSString *)titleForMonthAtRow:(NSInteger)row {
    NSString* title = [self.monthFormat copy];
    if ([title containsString:kMonthCodeFormat]) {
        title = [title stringByReplacingOccurrencesOfString:kMonthCodeFormat withString:[self titleForMonthIndexAtRow:row]];
    }
    if ([title containsString:kMonthNameFormat]) {
        title = [title stringByReplacingOccurrencesOfString:kMonthNameFormat withString:[self titleForMonthNameAtRow:row]];
    }
    return title;
}

- (NSString *)titleForMonthNameAtRow:(NSInteger)row {
    NSArray *const monthNames = [_dateFormatter monthSymbols];
    return monthNames[row];
}

- (NSString *)titleForMonthIndexAtRow:(NSInteger)row {
    return [NSString stringWithFormat:@"%@", @(row + 1)];
}

- (NSString *)titleForYearAtRow:(NSInteger)row {
    const NSInteger resultYear = self.yearRange.location + row;
    return [NSString stringWithFormat:@"%@", @(resultYear)];
}

- (void)updateSelectedDateAnimated:(BOOL)animated {
    switch (self.format) {
        case MAKMonthPickerFormatMonth:
            [self selectRow:_selectedMonth - 1 inComponent:0 animated:animated];
            break;
        case MAKMonthPickerFormatYear:
            [self selectRow:_selectedYear - _yearRange.location inComponent:0 animated:animated];
            break;
        default:
            [self selectRow:_selectedMonth - 1 inComponent:0 animated:animated];
            [self selectRow:_selectedYear - _yearRange.location inComponent:1 animated:animated];
            break;
    }
}
@end
