// Part of MeasurementKit <https://measurement-kit.github.io/>.
// MeasurementKit is free software. See AUTHORS and LICENSE for more
// information on the copying conditions.

#import <Foundation/Foundation.h>

@interface JSONFileReader : NSObject

@property (readonly, nonatomic) NSData *data;
@property (readonly, nonatomic) NSUInteger linesRead;
@property (strong, nonatomic) NSCharacterSet *lineTrimCharacters;
@property (readonly, nonatomic) NSStringEncoding stringEncoding;

- (instancetype)initWithFile:(NSString *)fileName encoding:(NSStringEncoding)encoding;
- (instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
- (NSString *)readLine;
- (NSString*)readLine :(NSInteger)number;
- (NSString *)readTrimmedLine;
- (void)setLineSearchPosition:(NSUInteger)position;

@end
