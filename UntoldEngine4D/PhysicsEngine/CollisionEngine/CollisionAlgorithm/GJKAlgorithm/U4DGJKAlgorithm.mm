//
//  U4DGJKAlgorithm.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 8/2/15.
//  Copyright (c) 2015 Untold Engine Studios. All rights reserved.
//

#include "U4DGJKAlgorithm.h"
#include "U4DSegment.h"
#include "U4DTriangle.h"
#include "U4DTetrahedron.h"
#include "U4DBoundingVolume.h"
#include "U4DDynamicModel.h"
#include "U4DVector3n.h"
#include "U4DStaticModel.h"


namespace U4DEngine {
    
    U4DGJKAlgorithm::U4DGJKAlgorithm(){
    
    }
    
    U4DGJKAlgorithm::~U4DGJKAlgorithm(){
    
    }
    
    bool U4DGJKAlgorithm::collision(U4DDynamicModel* uModel1, U4DDynamicModel* uModel2,float dt){
        
        /* KEEP THIS AS REFERENCE- Algorithm to detect collision between non-moving body.
        //clear Q
        cleanUp();
        
        U4DPoint3n originPoint(0,0,0);
        
        vPrevious.minkowskiPoint=U4DPoint3n(FLT_MAX,FLT_MAX,FLT_MAX);
        
        U4DBoundingVolume *boundingVolume1=uModel1->getNarrowPhaseBoundingVolume();
        U4DBoundingVolume *boundingVolume2=uModel2->getNarrowPhaseBoundingVolume();
        
        U4DVector3n dir(1,1,1);
        
        SIMPLEXDATA v=calculateSupportPointInDirection(boundingVolume1, boundingVolume2, dir);
        
        Q.push_back(v);
        
        dir=v.minkowskiPoint.toVector();
        
        dir.negate();
        
        SIMPLEXDATA p=calculateSupportPointInDirection(boundingVolume1, boundingVolume2, dir);
        
        //THIS IS THE CURRENT EXAMPLE- START
        while (v.minkowskiPoint.magnitudeSquare()>U4DEngine::collisionDistanceEpsilon*U4DEngine::collisionDistanceEpsilon) {

            vPrevious=v;

            Q.push_back(p);

            v.minkowskiPoint=determineClosestPointOnSimplexToPoint(originPoint, Q);

            //test condition: ||vPrevious||^2-||vCurrent||^2<=epsilon*||vCurrent||^2
            if (checkGJKTerminationCondition1(v)) {

                v=vPrevious;

                break;
            }

            if(determineMinimumSimplexInQ(v.minkowskiPoint,(int)Q.size())==false){
                
                v=vPrevious;
                
                break;
                
            }
            
            dir=v.minkowskiPoint.toVector();

            dir.negate();

            p=calculateSupportPointInDirection(boundingVolume1, boundingVolume2, dir);

            //test condition: ||v||^2-vdotw<=epsilon^2*||v||^2
            if (checkGJKTerminationCondition2(v,p,Q)) {
                
                return false;
            }
            
            //test condition: ||v||^2<=epsilon*max(element in Q)
            if (checkGJKTerminationCondition3(v,p,Q)) {
                //v=vPrevious;
                return false;
            }
            
        }

        if(Q.size()>4){
            return false;
        }
        
        if(v.minkowskiPoint.magnitudeSquare()<U4DEngine::minimumCollisionDistance){
            
            std::cout<<"Collision"<<std::endl;
            
        }
        */
        //End-KEEP THIS AS REFERENCE- Algorithm to detect collision between non-moving body.
        
        //GJK-TOI-Moving Objects implementation

        //clear Q
        cleanUp();

        U4DPoint3n originPoint(0,0,0);
        U4DPoint3n tempV(0,0,0); //variable to store previous value of v
        std::vector<float> barycentricPoints; //barycentric points
        float tClip=0.0; //time of impact
        U4DVector3n hitSpot(0,0,0); //hit spot
        U4DVector3n relativeCSOTranslation(0,0,0); //relative CSO translation

        vPrevious.minkowskiPoint=U4DPoint3n(FLT_MAX,FLT_MAX,FLT_MAX);

        U4DBoundingVolume *boundingVolume1;
        U4DBoundingVolume *boundingVolume2;

        //Determine the proper CSO translation vector and Support volumes for GJK
        relativeCSOTranslation=uModel2->getAbsolutePosition()-uModel1->getAbsolutePosition();

        U4DVector3n normalizedRelativeCSOTranslation=relativeCSOTranslation;
        normalizedRelativeCSOTranslation.normalize();

        U4DVector3n rVelocity=uModel2->getVelocity()+uModel1->getVelocity();
        rVelocity.normalize();


        if (rVelocity.dot(normalizedRelativeCSOTranslation)>=0.0) {

            boundingVolume1=uModel2->getNarrowPhaseBoundingVolume();
            boundingVolume2=uModel1->getNarrowPhaseBoundingVolume();

        }else{

            boundingVolume1=uModel1->getNarrowPhaseBoundingVolume();
            boundingVolume2=uModel2->getNarrowPhaseBoundingVolume();

            relativeCSOTranslation=relativeCSOTranslation*-1.0;
        }

        U4DVector3n dir(1,1,1);

        SIMPLEXDATA v=calculateSupportPointInDirection(boundingVolume1, boundingVolume2, dir);

        Q.push_back(v);

        dir=v.minkowskiPoint.toVector();

        dir.negate();

        SIMPLEXDATA p=calculateSupportPointInDirection(boundingVolume1, boundingVolume2, dir);

        while (v.minkowskiPoint.magnitudeSquare()>U4DEngine::collisionDistanceEpsilon*U4DEngine::collisionDistanceEpsilon) {

            if (v.minkowskiPoint.toVector().dot(p.minkowskiPoint.toVector())>(v.minkowskiPoint.toVector().dot(relativeCSOTranslation))*tClip) {

                if (v.minkowskiPoint.toVector().dot(relativeCSOTranslation)>0.0) {

                    tClip=v.minkowskiPoint.toVector().dot(p.minkowskiPoint.toVector())/v.minkowskiPoint.toVector().dot(relativeCSOTranslation);

                    if (tClip>1.0) {
                        return false;
                    }

                    hitSpot=relativeCSOTranslation*tClip;

                    //set time of impact for each model.

                    if (tClip<U4DEngine::minimumTimeOfImpact) {

                        float timeOfImpact=1.0-U4DEngine::minimumTimeOfImpact;

                        //minimum time step allowed
                        uModel1->setTimeOfImpact(timeOfImpact);
                        uModel2->setTimeOfImpact(timeOfImpact);

                    }else{

                        uModel1->setTimeOfImpact(1.0);
                        uModel2->setTimeOfImpact(1.0);

                    }

                }else{
                    return false;
                }
            }

            vPrevious=v;

            //p-hitSpot
            p.minkowskiPoint=(hitSpot.toPoint()-p.minkowskiPoint).toPoint();

            Q.push_back(p);

            v.minkowskiPoint=determineClosestPointOnSimplexToPoint(originPoint, Q);
            
            //test condition 1
            //test condition: ||vPrevious||^2-||vCurrent||^2<=epsilon*||vCurrent||^2
            if (checkGJKTerminationCondition1(v)) {
                
                v=vPrevious;
                
                break;
            }
            
            //determine the minimum simplex.
            if(determineMinimumSimplexInQ(v.minkowskiPoint,(int)Q.size())==false){
                
                v=vPrevious;
                
                break;
            }

            dir=v.minkowskiPoint.toVector();

            dir.negate();

            p=calculateSupportPointInDirection(boundingVolume1, boundingVolume2, dir);

            //test condition 2
            //test condition: ||v||^2-vdotw<=epsilon^2*||v||^2
            if (checkGJKTerminationCondition2(v,p,Q)) {
                
                break;
            }
            
            //test condition 3
            //test condition: ||v||^2<=epsilon*max(element in Q)
            if (checkGJKTerminationCondition3(v,p,Q)) {
                
                break;
            }
            
        }


        if (Q.size()>4) {
            return false;
        }
        
        
        if(v.minkowskiPoint.magnitudeSquare()<U4DEngine::collisionDistanceEpsilon){
            
            if(v.minkowskiPoint.toVector()==U4DVector3n(0.0,0.0,0.0)){
                v=vPrevious;
            }
            
            closestPointToOrigin=v.minkowskiPoint;
            
            contactCollisionNormal=v.minkowskiPoint.toVector();
            
            //normalize contact normal
            contactCollisionNormal.normalize();

            //closest collision point
            std::vector<U4DPoint3n> closestCollisionPoints=closestBarycentricPoints(closestPointToOrigin, Q);

            closestCollisionPoint=(closestCollisionPoints.at(0)+closestCollisionPoints.at(1))*0.5;
            
            return true;
            
        }
        

        return false;
        
    }
    
    bool U4DGJKAlgorithm::determineMinimumSimplexInQ(U4DPoint3n& uClosestPointToOrigin,int uNumberOfSimplexInContainer){
        
        bool minimumSimplexFound=false;
        
        if (uNumberOfSimplexInContainer==2) {
            
            //do line 
            minimumSimplexFound=determineLinearCombinationOfPtInLine(uClosestPointToOrigin);
            
        }else if(uNumberOfSimplexInContainer==3){
            //do triangle
            minimumSimplexFound=determineLinearCombinationOfPtInTriangle(uClosestPointToOrigin);
            
        }else if(uNumberOfSimplexInContainer==4){
            //do tetrahedron
            minimumSimplexFound=determineLinearCombinationOfPtInTetrahedron(uClosestPointToOrigin);
        }
        
        return minimumSimplexFound;
        
    }
        
    bool U4DGJKAlgorithm::determineLinearCombinationOfPtInLine(U4DPoint3n& uClosestPointToOrigin){
        
        bool lineSimplexFound=false;
        
        SIMPLEXDATA tempSupportPointQA=Q.at(0);
        SIMPLEXDATA tempSupportPointQB=Q.at(1);
        
        U4DPoint3n a=Q.at(0).minkowskiPoint;
        U4DPoint3n b=Q.at(1).minkowskiPoint;
        
        U4DSegment segment(a,b);
        
        if (segment.isValid()) {
            
            lineSimplexFound=true;
            
            Q.clear();
            
            //check if point is equals to a
            if (a==uClosestPointToOrigin) {
                Q.push_back(tempSupportPointQA);
                
                //check if point is equals to b
            }else if(b==uClosestPointToOrigin){
                Q.push_back(tempSupportPointQB);
                
                //else point lies in segment ab
            }else{
                
                Q.push_back(tempSupportPointQA);
                Q.push_back(tempSupportPointQB);
            }
            
        }
        
        return lineSimplexFound;
        
    }

    bool U4DGJKAlgorithm::determineLinearCombinationOfPtInTriangle(U4DPoint3n& uClosestPointToOrigin){
        
        bool triangleSimplexFound=false;
        
        SIMPLEXDATA tempSupportPointQA=Q.at(0);
        SIMPLEXDATA tempSupportPointQB=Q.at(1);
        SIMPLEXDATA tempSupportPointQC=Q.at(2);
        
        
        U4DPoint3n a=Q.at(0).minkowskiPoint;
        U4DPoint3n b=Q.at(1).minkowskiPoint;
        U4DPoint3n c=Q.at(2).minkowskiPoint;
        
        U4DSegment ac(a,c);
        U4DSegment bc(b,c);
        U4DSegment ab(a,b);
        

        U4DTriangle triangle(a,b,c);
        
        if (triangle.isValid()) {
            
            triangleSimplexFound=true;
            
            //check if the point is in the triangle
            if (triangle.isPointOnTriangle(uClosestPointToOrigin)) {
                
                //clear Q
                Q.clear();
                
                
                //if point is a linear combination of ab
                if(ab.isPointOnSegment(uClosestPointToOrigin)){
                    
                    Q.push_back(tempSupportPointQA);
                    Q.push_back(tempSupportPointQB);
                    
                    //if point is a linear combination of ac
                }else if(ac.isPointOnSegment(uClosestPointToOrigin)){
                    
                    Q.push_back(tempSupportPointQA);
                    Q.push_back(tempSupportPointQC);
                    
                    //if point is a linear combination of bc
                }else if(bc.isPointOnSegment(uClosestPointToOrigin)){
                    
                    Q.push_back(tempSupportPointQB);
                    Q.push_back(tempSupportPointQC);
                    
                    //the point is part of the triangle but not found on edges.
                }else{
                    
                    Q.push_back(tempSupportPointQA);
                    Q.push_back(tempSupportPointQB);
                    Q.push_back(tempSupportPointQC);
                    
                }
                
            }
            
        }
        
        return triangleSimplexFound;
        
    }

    bool U4DGJKAlgorithm::determineLinearCombinationOfPtInTetrahedron(U4DPoint3n& uClosestPointToOrigin){
        
        bool tetraSimplexFound=false;
        
        SIMPLEXDATA tempSupportPointQA=Q.at(0);
        SIMPLEXDATA tempSupportPointQB=Q.at(1);
        SIMPLEXDATA tempSupportPointQC=Q.at(2);
        SIMPLEXDATA tempSupportPointQD=Q.at(3);
        
        U4DPoint3n a=Q.at(0).minkowskiPoint;
        U4DPoint3n b=Q.at(1).minkowskiPoint;
        U4DPoint3n c=Q.at(2).minkowskiPoint;
        U4DPoint3n d=Q.at(3).minkowskiPoint;
        
        U4DTriangle abc(a,b,c);
        U4DTriangle adb(a,d,b);
        U4DTriangle acd(a,c,d);
        U4DTriangle bdc(b,d,c);
        

        U4DTetrahedron tetrahedron(a,b,c,d);
        
        if (tetrahedron.isValid()) {
        
            tetraSimplexFound=true;
            
            //check if the point is in the tetrahedron
            
            if (tetrahedron.isPointInTetrahedron(uClosestPointToOrigin)) {
                
                //clear Q
                Q.clear();
                
                //if point is a linear combination of abc
                if(abc.isPointOnTriangle(uClosestPointToOrigin)){
                    
                    
                    Q.push_back(tempSupportPointQA);
                    Q.push_back(tempSupportPointQB);
                    Q.push_back(tempSupportPointQC);
                    
                    
                    determineMinimumSimplexInQ(uClosestPointToOrigin,(int)Q.size());
                    //if point is a linear combination of abd
                }else if(adb.isPointOnTriangle(uClosestPointToOrigin)){
                    
                    
                    Q.push_back(tempSupportPointQA);
                    Q.push_back(tempSupportPointQB);
                    Q.push_back(tempSupportPointQC);
                    
                    determineMinimumSimplexInQ(uClosestPointToOrigin,(int)Q.size());
                    //if point is a linear combination of acd
                }else if(acd.isPointOnTriangle(uClosestPointToOrigin)){
                    
                    
                    Q.push_back(tempSupportPointQA);
                    Q.push_back(tempSupportPointQC);
                    Q.push_back(tempSupportPointQD);
                    
                    determineMinimumSimplexInQ(uClosestPointToOrigin,(int)Q.size());
                    //if point is a linear combination of bcd
                }else if(bdc.isPointOnTriangle(uClosestPointToOrigin)){
                    
                    
                    Q.push_back(tempSupportPointQB);
                    Q.push_back(tempSupportPointQC);
                    Q.push_back(tempSupportPointQD);
                    
                    determineMinimumSimplexInQ(uClosestPointToOrigin,(int)Q.size());
                    //point is found in tetrahedron but not found on the triangle faces
                }else{
                    
                    Q.push_back(tempSupportPointQA);
                    Q.push_back(tempSupportPointQB);
                    Q.push_back(tempSupportPointQC);
                    Q.push_back(tempSupportPointQD);
                    
                }
                
            }
            
        }
        
        return tetraSimplexFound;
        
    }
    
    std::vector<U4DPoint3n> U4DGJKAlgorithm::closestBarycentricPoints(U4DPoint3n& uClosestPointToOrigin, std::vector<SIMPLEXDATA> uQ){
        
        //get the barycentric points of the collision
        std::vector<float> barycentricPoints=determineBarycentricCoordinatesInSimplex(uClosestPointToOrigin, uQ);
        
        U4DPoint3n closestPointsModel1(0,0,0);
        U4DPoint3n closestPointsModel2(0,0,0);
        
        for (int i=0; i<barycentricPoints.size(); i++) {
            
            closestPointsModel1+=uQ.at(i).sa*barycentricPoints.at(i);
            closestPointsModel2+=uQ.at(i).sb*barycentricPoints.at(i);
        }
        
        
        std::vector<U4DPoint3n> closestPoints{closestPointsModel1,closestPointsModel2};
        
        return closestPoints;
        
    }
    
    std::vector<SIMPLEXDATA> U4DGJKAlgorithm::getCurrentSimpleStruct(){
        
        return Q;
        
    }
    
    U4DPoint3n U4DGJKAlgorithm::getClosestPointToOrigin(){
        
        return closestPointToOrigin;
        
    }
    
    U4DPoint3n U4DGJKAlgorithm::getClosestCollisionPoint(){
        
        return closestCollisionPoint;
        
    }
    
    U4DVector3n U4DGJKAlgorithm::getContactCollisionNormal(){
        
        return contactCollisionNormal;
    }
    
    bool U4DGJKAlgorithm::checkGJKTerminationCondition1(SIMPLEXDATA &uV){
        
        //test condition: ||vPrevious||^2-||vCurrent||^2<=epsilon*||vCurrent||^2
        //in theory, each new v should be shorter than the previous one. So terminate as soon as this occurs
        
        return (vPrevious.minkowskiPoint.magnitudeSquare()-uV.minkowskiPoint.magnitudeSquare()<=U4DEngine::collisionDistanceEpsilon*uV.minkowskiPoint.magnitudeSquare());
        
    }
    
    bool U4DGJKAlgorithm::checkGJKTerminationCondition2(SIMPLEXDATA &uV, SIMPLEXDATA &uP, std::vector<SIMPLEXDATA> uQ){
        
        //test condition: ||v||^2-vdotw<=epsilon^2*||v||^2
        return (uV.minkowskiPoint.magnitudeSquare()-uV.minkowskiPoint.toVector().dot(uP.minkowskiPoint.toVector())<=U4DEngine::collisionDistanceEpsilon*U4DEngine::collisionDistanceEpsilon*uV.minkowskiPoint.magnitudeSquare());
        
    }
    
    bool U4DGJKAlgorithm::checkGJKTerminationCondition3(SIMPLEXDATA &uV, SIMPLEXDATA &uP, std::vector<SIMPLEXDATA> uQ){
        
        //test condition:||v||^2<=epsilon*max(element in Q)
        
        //This test condition is used in case of a (near) contact, v will approximate zero, in which case previous
        //termination condition is not likely to be met
        float collisiontToleranceEpsilon=1.0e-6f;
        
        return (uV.minkowskiPoint.magnitudeSquare()<=collisiontToleranceEpsilon*getMaxSimplexInQ(uQ).minkowskiPoint.toVector().magnitudeSquare());
    }
    
    
    SIMPLEXDATA U4DGJKAlgorithm::getMaxSimplexInQ(std::vector<SIMPLEXDATA> uQ){
        
        float maxSimplexDistance=-FLT_MIN;
        
        SIMPLEXDATA maximumSimplex;
        
        for(auto n:uQ){
            
            float currentSimplexDistance=n.minkowskiPoint.toVector().magnitudeSquare();
            
            if (currentSimplexDistance>maxSimplexDistance) {
                
                maxSimplexDistance=currentSimplexDistance;
                
                maximumSimplex=n;
            }
        }
        
        return maximumSimplex;
        
    }
    
    void U4DGJKAlgorithm::cleanUp(){
        Q.clear();
        
        //Commented these values
        //closestPointToOrigin.zero();
        //closestCollisionPoint.zero();
        //contactCollisionNormal=U4DVector3n(0,1,0);
    }
    
}
