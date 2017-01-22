//
//  Missile.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 1/22/17.
//  Copyright © 2017 Untold Game Studio. All rights reserved.
//

#ifndef Missile_hpp
#define Missile_hpp

#include <stdio.h>
#include "U4DGameObject.h"
#include "UserCommonProtocols.h"
#include "U4DCallback.h"
#include "U4DTimer.h"

class Missile:public U4DEngine::U4DGameObject {
    
private:
    
    GameEntityState entityState;
    U4DEngine::U4DCallback<Missile>* scheduler;
    U4DEngine::U4DTimer *timer;
    
public:
    
    Missile();
    
    ~Missile();
    
    void init(const char* uName, const char* uBlenderFile);
    
    void update(double dt);
    
    void changeState(GameEntityState uState);
    
    void setState(GameEntityState uState);
    
    GameEntityState getState();
    
};
#endif /* Missile_hpp */
