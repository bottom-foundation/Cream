//
//  MangaViewController.h
//  Water
//
//  Created by Snoolie Keffaber on 10/3/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MangaViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *mangaPagesView;
@property (nonatomic, assign, readwrite) long nhentaiId;
@property (nonatomic, assign, readwrite) short pageNum;
-(UIImage *)imageFromGETUrl:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
