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

    // _mangaPageImage.image = [self imageFromGETUrl:[NSString stringWithFormat:@"https://t3-nhentai-net.translate.goog/galleries/%ld/cover.jpg?_x_tr_sl=fr&_x_tr_tl=en&_x_tr_hl=en-US&_x_tr_pto=wapp",[[responseDict objectForKey:@"media_id"]integerValue]]];
    
    CGSize contentSize = _mangaPagesView.frame.size;
    contentSize.width = _mangaPagesView.frame.size.width * maxNumPages;
    [_mangaPagesView setContentSize:contentSize];
    [_mangaPagesView setDelegate:self];
    [_mangaPagesView setPagingEnabled:YES];
    [_mangaPagesView setBounces:NO];
    [_mangaPagesView setScrollsToTop:NO];
    [_mangaPagesView setScrollEnabled:YES];
    [_mangaPagesView setShowsHorizontalScrollIndicator:NO];
    [_mangaPagesView setShowsVerticalScrollIndicator:NO];
    
    [self setPageNum:1];
    
    for (int i = 0; i < [numPages integerValue]; i++) {
        if (i < 4) {
            UIImageView *imgView = [[UIImageView alloc]initWithImage:[self imageWithImage:[self imageFromGETUrl:[NSString stringWithFormat:@"https://i3-nhentai-net.translate.goog/galleries/%ld/%hd.jpg?_x_tr_sl=fr&_x_tr_tl=en&_x_tr_hl=en-US&_x_tr_pto=wapp",[[responseDict objectForKey:@"media_id"]integerValue],[self pageNum]]] scaledToSize:CGSizeMake(_mangaPagesView.frame.size.width, _mangaPagesView.frame.size.height)]];
            [_mangaPagesView addSubview:imgView];
            [self setPageNum:[self pageNum] + 1];
        }
    }
    
    // Do any additional setup after loading the view.
}

-(UIImage *)imageFromGETUrl:(NSString *)url {
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]];
    return [UIImage imageWithData:imageData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self pageNum] < maxNumPages) {
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[self imageWithImage:[self imageFromGETUrl:[NSString stringWithFormat:@"https://i3-nhentai-net.translate.goog/galleries/%ld/%hd.jpg?_x_tr_sl=fr&_x_tr_tl=en&_x_tr_hl=en-US&_x_tr_pto=wapp",[[responseDict objectForKey:@"media_id"]integerValue],[self pageNum]]] scaledToSize:CGSizeMake(_mangaPagesView.frame.size.width, _mangaPagesView.frame.size.height)]];
        [_mangaPagesView addSubview:imgView];
        [self setPageNum:[self pageNum] + 1];
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
