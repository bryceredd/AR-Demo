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
    
    UIView* face;
    UIView* leftEye;
    UIView* rightEye;
    UIView* mouth;
    
    float scl;
    
    BOOL isScanningForFace;
    
    CGSize screenSize;
}
-(void) scanFaces;
-(void) setupCGContext;
-(void) scanFaces:(CIImage*)image;
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation ARLViewController
@synthesize glkView;
@synthesize context;


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setMultipleTouchEnabled:YES];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    coreImageContext = [CIContext contextWithEAGLContext:self.context];
    
    NSError * error;
    session = [[AVCaptureSession alloc] init];
    
    [session beginConfiguration];
    [session setSessionPreset:AVCaptureSessionPresetiFrame1280x720];
    
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    [session addInput:input];
    
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES]; 
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; 	
    
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [session addOutput:dataOutput];
    [session commitConfiguration];
    [session startRunning];
    
    CGSize scrn = [UIScreen mainScreen].bounds.size;
    //UIScreen mainScreen.bounds returns the device in portrait, we need to switch it to landscape
    screenSize = CGSizeMake(scrn.height, scrn.width);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scl = [[UIScreen mainScreen] scale];
        screenSize = CGSizeMake(screenSize.width * scl, screenSize.height * scl);
    } 
  
    [self setupCGContext];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    float heightSc = screenSize.height/(float)CVPixelBufferGetHeight(pixelBuffer);
    float widthSc = screenSize.width/(float)CVPixelBufferGetWidth(pixelBuffer);
    
    heightSc = widthSc = 1;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(widthSc, heightSc);
    transform = CGAffineTransformRotate(transform, degreesToRadian(180));
    
    image = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, image, @"inputTransform", [NSValue valueWithCGAffineTransform:transform],nil].outputImage; 
    
    [coreImageContext drawImage:image atPoint:CGPointZero fromRect:[image extent] ];
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    
    
    
    if(!isScanningForFace) {
        isScanningForFace = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *features = [detector featuresInImage:image];
            NSLog(@"%d faces detected", features.count);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                for(CIFaceFeature* feature in features) {
                    
                    if(!face) {
                        face = [[UIView alloc] initWithFrame:feature.bounds];
                        [face setBackgroundColor:[[UIColor yellowColor] colorWithAlphaComponent:0.4]];
                        [self.view addSubview:face];
                    }
                    
                    
                    CGRect imageRect = [image extent];
                    NSLog(@"\nimageRect: %@ \nfaceBound: %@", NSStringFromCGRect(imageRect), NSStringFromCGRect(feature.bounds));
                    
                    face.frame = feature.bounds;
                }
            });
            
            isScanningForFace = NO;
        });
    }
}


- (void)setupCGContext {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * screenSize.width;
    NSUInteger bitsPerComponent = 8;
    cgcontext = CGBitmapContextCreate(NULL, screenSize.width, screenSize.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);
}

- (void)viewDidUnload {
    [self setGlkView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    
}

@end
