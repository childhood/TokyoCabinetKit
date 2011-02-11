#import <TokyoCabinet/TokyoCabinet.h>

@interface Setting : TCTableModel {
}

@property (nonatomic, assign) NSString *name;
@property (nonatomic) int age;

@end
