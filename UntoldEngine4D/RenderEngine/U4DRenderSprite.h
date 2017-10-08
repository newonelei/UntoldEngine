//
//  U4DRenderSprite.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 8/23/17.
//  Copyright © 2017 Untold Game Studio. All rights reserved.
//

#ifndef U4DRenderSprite_hpp
#define U4DRenderSprite_hpp

#include <stdio.h>
#include "U4DRenderManager.h"
#include "U4DRenderImage.h"
#include "U4DMatrix4n.h"
#include "U4DVector3n.h"
#include "U4DVector4n.h"
#include "U4DVector2n.h"
#include "U4DIndex.h"


namespace U4DEngine {
    
    class U4DRenderSprite:public U4DRenderImage {
        
    private:
        
        U4DImage *u4dObject;
        
        U4DVector2n spriteOffset;
        
        //uniforms
        id<MTLBuffer> uniformSpriteBuffer;
        
    public:
        
        U4DRenderSprite(U4DImage *uU4DImage);
        
        ~U4DRenderSprite();
        
        void loadMTLAdditionalInformation();
        
        void render(id <MTLRenderCommandEncoder> uRenderEncoder);
        
        void setSpriteDimension(float uSpriteWidth,float uSpriteHeight, float uAtlasWidth,float uAtlasHeight);
        
        void updateSpriteBufferUniform();
        
        void setSpriteOffset(U4DVector2n &uSpriteOffset);
        
    };
    
}
#endif /* U4DRenderSprite_hpp */