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
-(CGRect) monsterFrameFromFace:(CGRect)face;
-(void) deviceOrientationDidChange:(id)sender;
@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic, strong) UIAccelerometer* accelerometer;
@end

@implementation ARLViewController
@synthesize face;
@synthesize monster;
@synthesize context;
@synthesize accelerometer;


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[ARLPlayersManager instance] addDelegate:self];
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
	self.accelerometer.updateInterval = 0.25;
	self.accelerometer.delegate = self;
    
    	// Listen for changes in device orientation
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];	


    
    NSError * error;
    
    detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    //CGSize scrn = [UIScreen mainScreen].bounds.size;
    //UIScreen mainScreen.bounds returns the device in portrait, we need to switch it to landscape
    screenSize = self.view.frame.size;
    
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
    [session setSessionPreset:AVCaptureSessionPresetiFrame960x540];
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

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
 
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
 
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
 
    float heightSc = screenSize.width/(float)CVPixelBufferGetHeight(pixelBuffer);
    float widthSc = screenSize.height/(float)CVPixelBufferGetWidth(pixelBuffer);
    
    heightSc = widthSc = MAX(heightSc, widthSc);
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(degreesToRadian(-90));
    transform = CGAffineTransformScale(transform, widthSc, heightSc);
    
    image = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, image, @"inputTransform", [NSValue valueWithCGAffineTransform:transform],nil].outputImage;
 
    
 
    [coreImageContext drawImage:image atPoint:CGPointZero fromRect:[image extent]];
    
    
    if(!isScanningForFace) {
        isScanningForFace = YES;
        
        float scale = 6.f;
 
                      
        CGAffineTransform smallTransform = CGAffineTransformMakeScale(1/scale, 1/scale);
        smallTransform = CGAffineTransformTranslate(smallTransform, 0, CGRectGetHeight([image extent]));
        
        
        CIImage* smallImage = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, image, @"inputTransform", [NSValue valueWithCGAffineTransform:smallTransform], nil].outputImage; 
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            NSArray *features = [detector featuresInImage:smallImage];
            CGRect smallImageRect = [smallImage extent];
            
            for(CIFaceFeature* feature in features) {
                CGRect featureRect = [feature bounds];
                
                float ratio = screenSize.height / screenSize.width;
                float actualVisibleHeight = ratio * CGRectGetWidth(smallImageRect);
                float upperCroppedPortion = CGRectGetHeight(smallImageRect) - actualVisibleHeight;
                
                featureRect.origin.y = (smallImageRect.size.height - upperCroppedPortion) - featureRect.origin.y - featureRect.size.height;
                
                
                float retinaFactor = retina? 2.f:1.f;
                CGRect rect = CGRectMake(
                    featureRect.origin.x*scale/retinaFactor, 
                    featureRect.origin.y*scale/retinaFactor, 
                    featureRect.size.width*scale/retinaFactor, 
                    featureRect.size.height*scale/retinaFactor);
                    
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:.1 animations:^{
                        self.face.frame = rect;
                        self.monster.frame = [self monsterFrameFromFace:rect];
                        self.monster.alpha = 1.f;
                    }];
                });
                
                break;
            }
            
            if(![features count]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:1.25 animations:^{
                        self.monster.alpha = 0;
                    }];
                });
            }
            
            [coreImageContext drawImage:image atPoint:CGPointZero fromRect:[image extent]];
            
            isScanningForFace = NO;
        });
    }
    
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (CGRect) monsterFrameFromFace:(CGRect)rect {
    
    float ratio = CGRectGetWidth(monster.frame) / CGRectGetHeight(monster.frame);
    
    rect.size.width = rect.size.height * ratio;
    
    CGRect monsterRect = CGRectScale(rect, 3);
    
    return monsterRect;
}

- (void)viewDidUnload {
    [self setFace:nil];
    [self setMonster:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)radar:(id)sender {
    UIViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ARLRadarViewController"];
    
    [self presentModalViewController:controller animated:YES];
}


// calculate labels

- (void) deviceOrientationDidChange:(id)sender {

}

- (void) didReceiveUpdate {
    
}



@end
