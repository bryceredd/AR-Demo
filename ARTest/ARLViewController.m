//
//  ARLViewController.m
//  ARTest
//
//  Created by Bryce Redd on 2/3/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "ARLViewController.h"

@interface ARLViewController() {
AVCaptureSession *session;
    CIContext *coreImageContext;
    GLuint _renderBuffer;
    CGContextRef cgcontext;
    CIDetector* detector;
    
    BOOL isScanningForFace;
    
    CGSize screenSize;
}
-(void)setupCGContext;
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation ARLViewController
@synthesize face;
@synthesize context;


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError * error;
    
    detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    CGSize scrn = [UIScreen mainScreen].bounds.size;
    //UIScreen mainScreen.bounds returns the device in portrait, we need to switch it to landscape
    screenSize = CGSizeMake(scrn.height, scrn.width);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        float scl = [[UIScreen mainScreen] scale];
        screenSize = CGSizeMake(screenSize.width * scl, screenSize.height * scl);
    }
    
    
    
    GLKView* view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    coreImageContext = [CIContext contextWithEAGLContext:self.context];
    
    
    
    
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES]; 
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; 	
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    session = [[AVCaptureSession alloc] init];
    [session beginConfiguration];
    [session setSessionPreset:AVCaptureSessionPresetiFrame1280x720];
    [session addInput:input];
    [session addOutput:dataOutput];
    [session commitConfiguration];
    [session startRunning];
    
    [self setupCGContext];
    
}

- (void)setupCGContext {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * screenSize.width;
    NSUInteger bitsPerComponent = 8;
 
    cgcontext = CGBitmapContextCreate(NULL, screenSize.width, screenSize.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
 
    CGColorSpaceRelease(colorSpace);
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
 
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
 
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
 
    float heightSc = screenSize.height/(float)CVPixelBufferGetHeight(pixelBuffer);
    float widthSc = screenSize.width/(float)CVPixelBufferGetWidth(pixelBuffer);
    
    heightSc = widthSc = MAX(heightSc, widthSc);
    
    CGAffineTransform transform = CGAffineTransformMakeScale(widthSc, heightSc);
    transform = CGAffineTransformRotate(transform, degreesToRadian(-90));
    
    image = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, image, @"inputTransform", [NSValue valueWithCGAffineTransform:transform],nil].outputImage;
 
    [coreImageContext drawImage:image atPoint:CGPointZero fromRect:[image extent]];
    
    
    if(!isScanningForFace) {
        isScanningForFace = YES;
        
        CGAffineTransform smallTransform = CGAffineTransformMakeScale(widthSc/4.f, heightSc/4.f);
        CIImage* smallImage = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, image, @"inputTransform", [NSValue valueWithCGAffineTransform:smallTransform], nil].outputImage; 
        
        float scaleWidth = widthSc / 4.f;
        float scaleHeight = heightSc / 4.f;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            NSArray *features = [detector featuresInImage:smallImage];
            NSLog(@"%d faces detected  %f %f", features.count, scaleWidth, scaleHeight);
            
            for(CIFaceFeature* feature in features) {
                NSLog(@"%@", NSStringFromCGRect([feature bounds]));
                
                CGRect rect = [feature bounds];
                
                rect.origin.y = (-(rect.origin.y + 50 + rect.size.width)) * 2.3;
                rect.origin.x *= 2.3; 
                rect.size.height *= 2.3f;
                rect.size.width *= 2.3f;
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:.25 animations:^{
                        self.face.frame = rect;
                    }];
                });
            }
            
            [coreImageContext drawImage:image atPoint:CGPointZero fromRect:[image extent]];
            
            isScanningForFace = NO;
        });
    }
    
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}



- (void)viewDidUnload {
    [self setFace:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)radar:(id)sender {
    UIViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ARLRadarViewController"];
    
    [self presentModalViewController:controller animated:YES];
}

@end
