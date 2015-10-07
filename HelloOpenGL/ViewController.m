//
//  ViewController.m
//  HelloOpenGL
//
//  Created by ZomeeLee on 10/6/15.
//  Copyright (c) 2015 ZomeeLee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) EAGLContext* context;
@property (strong, nonatomic) GLKBaseEffect* effect;
@property (nonatomic) GLuint program;
@property (nonatomic) GLKMatrix4 projectionMatrix;
@property (nonatomic) GLKMatrix4 modelViewMatrix;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //initial context with the version of API
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    //initial view
    GLKView* view = (GLKView*)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
    
    //initial base effect
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    //initial vertex data
    GLfloat squareVertexData[48] =
    {
        0.5f,   0.5f,  -0.9f,  0.0f,   0.0f,   1.0f,   1.0f,   1.0f,
        -0.5f,   0.5f,  -0.9f,  0.0f,   0.0f,   1.0f,   0.0f,   1.0f,
        0.5f,  -0.5f,  -0.9f,  0.0f,   0.0f,   1.0f,   1.0f,   0.0f,
        0.5f,  -0.5f,  -0.9f,  0.0f,   0.0f,   1.0f,   1.0f,   0.0f,
        -0.5f,   0.5f,  -0.9f,  0.0f,   0.0f,   1.0f,   0.0f,   1.0f,
        -0.5f,  -0.5f,  -0.9f,  0.0f,   0.0f,   1.0f,   0.0f,   0.0f,
    };
    
    //alloc buffer and copy vertex data into the buffer
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    //copy the data of the buffer into the general-purpose vertex attrib array
    
    //position
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 4 * 8, (char*)NULL + 0);
    
    //normal
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 4 * 8, (char*)NULL + 12);
    
    //texcoord
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 3, GL_FLOAT, GL_FALSE, 4 * 8, (char*)NULL + 24);
    
    
    //initial projecton matrix and modelview matrix
    CGSize size = self.view.bounds.size;
    float aspect = (float)size.width / (float)size.height;
    
    self.projectionMatrix =  GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f), aspect, 0.1, 10.0);
    self.effect.transform.projectionMatrix = self.projectionMatrix;
    
    self.modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -1.0f);
    self.effect.transform.modelviewMatrix = self.modelViewMatrix;
    
    //load texture
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tex1" ofType:@"jpg"];
    //adjust the origin for the texture coordinate system
    NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:option error:nil];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = textureInfo.name;
    
    
    //method 2: use shaders
    //load shaders
    NSString *vertexFile = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@"shader"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@"shader"];
    
    self.program = [self loadShaders:vertexFile frag:fragFile];
    
//    //test
//    GLint params;
//    glGetProgramiv(self.program, GL_LINK_STATUS, &params);
//    NSLog(@"%d", params);
    
    //pass parameters to the shaders
    glBindAttribLocation(self.program, 0, "position");
    glBindAttribLocation(self.program, 3, "texcoord");
    glLinkProgram(self.program);
    
    glUseProgram(self.program);
    GLint texture = glGetUniformLocation(self.program, "texture");
    glUniform1i(texture, 0);
    

    
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
}

- (GLint)loadShaders:(NSString *)vert frag:(NSString *)frag{
    
    GLint pprogram = glCreateProgram();
    GLuint vertexShader, fragmentShader;
    
    [self compileShader:&vertexShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragmentShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(pprogram, vertexShader);
    glAttachShader(pprogram, fragmentShader);
    
    glLinkProgram(pprogram);
    
    return pprogram;
    
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller{

}

- (void)update{

    //specify transform matrix
    GLint mvpMatrix = glGetUniformLocation(self.program, "modelViewProjectionMatrix");
    //rotate the modelViewMatrix to distinguish the result with the formmer method
    self.modelViewMatrix = GLKMatrix4Rotate(self.modelViewMatrix,
                                            GLKMathDegreesToRadians(1.0f), 0.0f, 0.0f, 1.0f);
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, self.modelViewMatrix);
    glUniformMatrix4fv(mvpMatrix, 1, GL_FALSE, modelViewProjectionMatrix.m);

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.2f, 0.5f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    glUseProgram(self.program);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
