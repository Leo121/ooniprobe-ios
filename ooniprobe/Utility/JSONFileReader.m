// Part of MeasurementKit <https://measurement-kit.github.io/>.
// MeasurementKit is free software. See AUTHORS and LICENSE for more
// information on the copying conditions.

#import "JSONFileReader.h"

static unsigned char const BRLineReaderDelimiter = '\n';

@implementation JSONFileReader
{
    NSRange _lastRange;
}

- (instancetype)initWithFile:(NSString *)fileName encoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (self) {
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        _data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedAlways error:&error];
        if (!_data) {
            NSLog(@"%@", [error localizedDescription]);
        }
        _stringEncoding = encoding;
        _lineTrimCharacters = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    }
    
    return self;
}

- (instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (self) {
        _data = data;
        _stringEncoding = encoding;
        _lineTrimCharacters = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    }
    
    return self;
}

- (NSString *)readLine
{
    NSUInteger dataLength = [_data length];
    NSUInteger beginPos = _lastRange.location + _lastRange.length;
    NSUInteger endPos = 0;
    if (beginPos == dataLength) {
        // End of file
        return nil;
    }
    
    unsigned char *buffer = (unsigned char *)[_data bytes];
    for (NSUInteger i = beginPos; i < dataLength; i++) {
        endPos = i;
        if (buffer[i] == BRLineReaderDelimiter) break;
    }
    
    // End of line found
    _lastRange = NSMakeRange(beginPos, endPos - beginPos + 1);
    NSData *lineData = [_data subdataWithRange:_lastRange];
    NSString *line = [[NSString alloc] initWithData:lineData encoding:_stringEncoding];
    _linesRead++;
    
    return line;
}

-(NSString*)readLine:(NSInteger)number{
    NSString *content;
    NSInteger i = 0;
    while ((content = [self readLine]) != nil) {
        if (i == number)
            return content;
        i++;
    }
    return content;
}

- (NSString *)readTrimmedLine
{
    return [[self readLine] stringByTrimmingCharactersInSet:_lineTrimCharacters];
}

- (void)setLineSearchPosition:(NSUInteger)position
{
    _lastRange = NSMakeRange(position, 0);
    _linesRead = 0;
}

@end
