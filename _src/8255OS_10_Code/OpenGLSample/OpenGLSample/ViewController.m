//
//  ViewController.m
//  OpenGLSample
//
//  Created by Mayank on 12/26/14.
//  Copyright (c) 2014 Shabana. All rights reserved.
//

#import "ViewController.h"

typedef struct {
    GLKVector3 position;
    GLKVector2 textureCoordinates;
} Vertex;

const Vertex CubeVertices[] = {
    {{-1, -1, 1}, {0,0}},
    {{1, -1, 1}, {1,0}},
    {{1, 1, 1}, {1,1}},
    {{-1, 1, 1}, {0,1}},
    
    {{-1, -1, -1}, {1,0}},
    {{1, -1, -1}, {0,0}},
    {{1, 1, -1}, {0,1}},
    {{-1, 1, -1}, {1,1}},
};

const GLubyte CubeTriangles[] = {
    0, 1, 2,
    2, 3, 0,
    4, 5, 6,
    6, 7, 4,
    
    7, 4, 0,
    0, 3, 7,
    
    2, 1, 5,
    5, 6, 2,
    
    7, 3, 6,
    6, 2, 3,
    
    4, 0, 5,
    5, 1, 0,
};

@interface ViewController () {
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLKBaseEffect* _squareEffect;
    float rotation;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    GLKView* view = (GLKView*)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glEnable(GL_DEPTH_TEST);
      glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(CubeVertices), CubeVertices, GL_STATIC_DRAW);
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(CubeTriangles), CubeTriangles, GL_STATIC_DRAW);
    _squareEffect = [[GLKBaseEffect alloc] init];
    
    float aspectRatio = self.view.bounds.size.width / self.view.bounds.size.height;
    float fieldOfViewDegrees = 60.0;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(fieldOfViewDegrees), aspectRatio, 0.1, 10.0);
    _squareEffect.transform.projectionMatrix = projectionMatrix;
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"Texture" ofType:@"png"];
    NSError* error = nil;
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:imagePath options:nil error:&error];
    if (error != nil) {
        NSLog(@"Problem loading texture: %@", error);
    }
    _squareEffect.texture2d0.name = texture.name;
    _squareEffect.useConstantColor = YES;
    _squareEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
}

- (void) update {
    
    NSTimeInterval timeInterval = self.timeSinceLastUpdate;
    float rotationSpeed = 15 * timeInterval;
    rotation += rotationSpeed;
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(45));
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(rotation));
    
    _squareEffect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [_squareEffect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), offsetof(Vertex, position));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)offsetof(Vertex, textureCoordinates));
    int numberOfVertices = sizeof(CubeTriangles)/sizeof(CubeTriangles[0]);
    glDrawElements(GL_TRIANGLES, numberOfVertices, GL_UNSIGNED_BYTE, 0);
}

@end
