//
//  MangaViewController.m
//  Water
//
//  Created by Snoolie Keffaber on 10/3/22.
//

#import "MangaViewController.h"

short maxNumPages;

NSDictionary *responseDict;

@interface MangaViewController ()

@end

@implementation MangaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    // [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://nhentai.net/api/gallery/%ld",[self nhentaiId]]]];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://nhentai-net.translate.goog/api/gallery/%ld?_x_tr_sl=fr&_x_tr_tl=en&_x_tr_hl=en-US&_x_tr_pto=wapp",[self nhentaiId]]]];
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*" forHTTPHeaderField:@"Access-Control-Allow-Origin"];

    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error GET, HTTP status code %li", (long)[responseCode statusCode]);
        exit(7829);
    }
    
    responseDict = [NSJSONSerialization JSONObjectWithData:oResponseData options:kNilOptions error:&error];
    
    NSLog(@"Response: %@",responseDict);
    
    NSString *numPages = [responseDict objectForKey:@"num_pages"];
    
    maxNumPages = (short)[numPages integerValue];
    
    NSLog(@"Pages: %@",numPages);
    
    [self.navigationItem setTitle:[[responseDict objectForKey:@"title"]objectForKey:@"pretty"]];
    
    [self setPageNum:1];
    
    UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-30, self.view.frame.size.width, 30)];
    [pageControl setNumberOfPages:maxNumPages];
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl];
    
    [scrollView setPagingEnabled:YES];
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width*5, self.view.frame.size.height)];
    
    for (int i = 0; i < [numPages integerValue]; i++) {
        if (i < 4) {
            UIImageView *imgView = [[UIImageView alloc]initWithImage:[self imageFromGETUrl:[NSString stringWithFormat:@"https://i3-nhentai-net.translate.goog/galleries/%ld/%hd.jpg?_x_tr_sl=fr&_x_tr_tl=en&_x_tr_hl=en-US&_x_tr_pto=wapp",[[responseDict objectForKey:@"media_id"]integerValue],[self pageNum]]]];
            [imgView setFrame:CGRectMake(self.view.frame.size.width*i, 0, self.view.frame.size.width, scrollView.frame.size.height)];
            [imgView setUserInteractionEnabled:YES];
            UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pageTapped)];
            [imgTap setNumberOfTapsRequired:1];
            [imgView addGestureRecognizer:imgTap];
            [scrollView addSubview:imgView];
            [self setPageNum:[self pageNum] + 1];
        }
    }
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self setPageNum:1];
}

-(UIImage *)imageFromGETUrl:(NSString *)url {
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]];
    return [UIImage imageWithData:imageData];
}

-(void)pageTapped {
    if (self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)pageDoubleTapped:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"double tap press");
    if (!self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    CGPoint tappedPoint= [gestureRecognizer locationInView:gestureRecognizer.view];
    [scrollView zoomToRect:CGRectMake(tappedPoint.x/2.0, tappedPoint.y/2.0, 160.0, 160.0) animated:YES];
}

- (UIView*) viewForZoomingInScrollView: (UIScrollView*)scrollView{
    //zoom temp, doesn't work properly atm, need to get current subview on screen
    return scrollView.subviews[0];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (pagesLoaded < [[responseDict objectForKey:@"num_pages"]integerValue]) {
        NSLog(@"Loading Page...");
        MangaPageView *pageView = [[MangaPageView alloc]init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *airplanes = [self imageFromGETUrl:[NSString stringWithFormat:@"https://i3.nhentai.net/galleries/%ld/%d.jpg",[[responseDict objectForKey:@"media_id"]integerValue],pagesLoaded+1]];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [pageView setImage:airplanes];
                [pageView setPageNum:pagesLoaded+1];
                [pageView setNhentaiId:[[responseDict objectForKey:@"media_id"]integerValue]];
                [pageView setDidLoadImage:YES];
                [pageView setFrame:CGRectMake(self.view.frame.size.width*pagesLoaded, 0, self.view.frame.size.width, scrollView.frame.size.height)];
                [pageView setUserInteractionEnabled:YES];
                UITapGestureRecognizer *pageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pageTapped)];
                [pageTap setNumberOfTapsRequired:1];
                [pageView addGestureRecognizer:pageTap];
                [scrollView addSubview:pageView];
                pagesLoaded++;
                NSLog(@"Page %d Loaded!",pagesLoaded);
            });
        });
    }
}

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
