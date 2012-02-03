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
    
    
    CGSize screenSize;
}
-(void)setupCGContext;
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation ARLViewController
@synthesize context;


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError * error;
    
    
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
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}



- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
