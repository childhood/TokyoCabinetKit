#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController {
@private
    UILabel *nameLabel;
    UILabel *ageLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *ageLabel;

@end
