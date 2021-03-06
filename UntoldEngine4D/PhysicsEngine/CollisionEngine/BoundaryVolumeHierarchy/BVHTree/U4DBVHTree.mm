//
//  BVHTree.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 2/13/16.
//  Copyright © 2016 Untold Engine Studios. All rights reserved.
//

#include "U4DBVHTree.h"

namespace U4DEngine {
    
    U4DBVHTree::U4DBVHTree():parent(nullptr),next(nullptr),splitIndex(0){
        
        prevSibling=this;
        lastDescendant=this;
        
        aabbVolume=new U4DAABB();
    }
    
    U4DBVHTree::~U4DBVHTree(){
        
        delete aabbVolume;
        
    }
    
    U4DAABB* U4DBVHTree::getAABBVolume(){
        return aabbVolume;
    }
    
    std::vector<U4DDynamicModel *> U4DBVHTree::getModelsContainer(){
        
        return modelsContainer;
    
    }
    
    void U4DBVHTree::addModelToContainer(U4DDynamicModel *uModel){
        
        modelsContainer.push_back(uModel);
    }
    
    void U4DBVHTree::addModelToContainerAtIndex(int uIndex, U4DDynamicModel *uModel){
        
        modelsContainer.at(uIndex)=uModel;
    }
    
    void U4DBVHTree::copyModelsContainer(std::vector<U4DDynamicModel *> uModelsContainer){
        
        modelsContainer=uModelsContainer;
    }

    //scenegraph methods
    void U4DBVHTree::addChild(U4DBVHTree *uChild){
        
        U4DBVHTree* lastAddedChild=getFirstChild();
        
        if(lastAddedChild==0){ //add as first child
            
            uChild->parent=this;
            
            uChild->lastDescendant->next=lastDescendant->next;
            
            lastDescendant->next=uChild;
            
            uChild->prevSibling=getLastChild();
            
            if (isLeaf()) {
                
                next=uChild;
                
            }
            
            getFirstChild()->prevSibling=uChild;
            
            changeLastDescendant(uChild->lastDescendant);
            
            
        }else{
            
            uChild->parent=lastAddedChild->parent;
            
            uChild->prevSibling=lastAddedChild->prevSibling;
            
            uChild->lastDescendant->next=lastAddedChild;
            
            if (lastAddedChild->parent->next==lastAddedChild) {
                lastAddedChild->parent->next=uChild;
            }else{
                lastAddedChild->prevSibling->lastDescendant->next=uChild;
            }
            
            lastAddedChild->prevSibling=uChild;
            
        }
        
    }
    
    void U4DBVHTree::removeChild(U4DBVHTree *uChild){
        
        U4DBVHTree* sibling = uChild->getNextSibling();
        
        if (sibling)
            sibling->prevSibling = uChild->prevSibling;
        else
            getFirstChild()->prevSibling = uChild->prevSibling;
        
        if (lastDescendant == uChild->lastDescendant)
            changeLastDescendant(uChild->prevInPreOrderTraversal());
        
        if (next == uChild)	// deleting first child?
            next = uChild->lastDescendant->next;
        else
            uChild->prevSibling->lastDescendant->next = uChild->lastDescendant->next;
        
    }
    
    U4DBVHTree *U4DBVHTree::prevInPreOrderTraversal(){
        
        U4DBVHTree* prev = 0;
        if (parent)
        {
            if (parent->next == this)
                prev = parent;
            else
                prev = prevSibling->lastDescendant;
        }
        return prev;
    }
    
    U4DBVHTree *U4DBVHTree::nextInPreOrderTraversal(){
        return next;
    }
    
    U4DBVHTree *U4DBVHTree::getFirstChild(){
        
        U4DBVHTree* child=NULL;
        if(next && (next->parent==this)){
            child=next;
        }
        
        return child;
    }
    
    U4DBVHTree *U4DBVHTree::getLastChild(){
        
        U4DBVHTree *child=getFirstChild();
        
        if(child){
            child=child->prevSibling;
        }
        
        return child;
    }
    
    U4DBVHTree *U4DBVHTree::getNextSibling(){
        
        U4DBVHTree* sibling = lastDescendant->next;
        if (sibling && (sibling->parent != parent))
            sibling = 0;
        return sibling;
    }
    
    
    U4DBVHTree *U4DBVHTree::getPrevSibling(){
        U4DBVHTree* sibling = 0;
        if (parent && (parent->next != this))
            sibling =prevSibling;
        return sibling;
    }
    
    void U4DBVHTree::changeLastDescendant(U4DBVHTree *uNewLastDescendant){
        
        U4DBVHTree *oldLast=lastDescendant;
        U4DBVHTree *ancestor=this;
        
        do{
            ancestor->lastDescendant=uNewLastDescendant;
            ancestor=ancestor->parent;
        }while (ancestor && (ancestor->lastDescendant==oldLast));
        
    }
    
    bool U4DBVHTree::isRoot(){
        
        bool value=false;
        
        if (parent==0) {
            
            value=true;
            
        }
        
        return value;
    }
    
    bool U4DBVHTree::isLeaf(){
        
        return (lastDescendant==this);
        
    }
    
    void U4DBVHTree::setSplitIndex(int uSplitIndex){
        
        splitIndex=uSplitIndex;
    }
    
    int U4DBVHTree::getSplitIndex(){
        
        return splitIndex;
    }

}
