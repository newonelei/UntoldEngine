//
//  GameAsset.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 7/14/17.
//  Copyright © 2017 Untold Game Studio. All rights reserved.
//

#include "GameAsset.h"

GameAsset::GameAsset(){
    
}

GameAsset::~GameAsset(){
    
}

bool GameAsset::init(const char* uModelName, const char* uBlenderFile){
    
    if (loadModel(uModelName, uBlenderFile)) {
    
        //setEnableShadow(true);
        //initAsPlatform(true);
        //enableCollisionBehavior();
        loadRenderingInformation();
        
        return true;
    }
    
    return false;
}

void GameAsset::update(double dt){
    
}