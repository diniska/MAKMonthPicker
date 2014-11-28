MAKMonthPicker
==============

[![CI Status](http://img.shields.io/travis/diniska/MAKMonthPicker.svg?style=flat)](https://travis-ci.org/diniska/MAKMonthPicker)
[![Version](https://img.shields.io/cocoapods/v/MAKMonthPicker.svg?style=flat)](http://cocoadocs.org/docsets/MAKMonthPicker)

iOS customizable month picker component

## Installation
The easiest way is to use [CocoaPods](http://cocoapods.org). It takes care of all required frameworks and third party dependencies:
```ruby
pod 'MAKMonthPicker', '~> 0.0'
```

## Usage example

```objective-c
self.monthPicker.format =  MAKMonthPickerFormatMonth | MAKMonthPickerFormatYear;
self.monthPicker.monthFormat = @"%n | %c";
self.monthPicker.date = [NSDate dateWithTimeIntervalSinceNow:-ktTimeInMonth];
self.monthPicker.yearRange = NSMakeRange(2000, 100);
```
The result looks like:

![image alt][1]
![image alt][2]
![image alt][3]

[1]: https://raw.githubusercontent.com/diniska/MAKMonthPicker/master/Screens/screen1.png
[2]: https://raw.githubusercontent.com/diniska/MAKMonthPicker/master/Screens/screen2.png
[3]: https://raw.githubusercontent.com/diniska/MAKMonthPicker/master/Screens/screen3.png
