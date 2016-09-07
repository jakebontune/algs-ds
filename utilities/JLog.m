//
// JLog.m
//

#import "JLog.h"

void JLog(NSString *format, ...) {
    va_list args;
    va_start (args, format);
    NSString *string;
    string = [[NSString alloc] initWithFormat: format  arguments: args];
    va_end (args);
    printf ("%s", [string UTF8String]);
}