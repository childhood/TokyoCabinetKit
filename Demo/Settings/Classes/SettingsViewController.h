#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIPickerView *picker;
}

@property (nonatomic, retain) IBOutlet UIPickerView *picker;

@end
