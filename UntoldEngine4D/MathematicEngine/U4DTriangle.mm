//
//  U4DTriangle.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 8/2/15.
//  Copyright (c) 2015 Untold Engine Studios. All rights reserved.
//

#include "U4DTriangle.h"
#include "U4DPoint3n.h"
#include "U4DVector3n.h"
#include "U4DNumerical.h"
#include <cmath>
#include <algorithm>

namespace U4DEngine {
    
    U4DTriangle::U4DTriangle():pointA(0.0,0.0,0.0),pointB(0.0,0.0,0.0),pointC(0.0,0.0,0.0){}
    
    U4DTriangle::U4DTriangle(U4DPoint3n& uPointA, U4DPoint3n& uPointB, U4DPoint3n& uPointC){
        
        pointA=uPointA;
        pointB=uPointB;
        pointC=uPointC;

    }

    U4DTriangle::~U4DTriangle(){}
    
    U4DTriangle::U4DTriangle(const U4DTriangle& a):pointA(a.pointA),pointB(a.pointB),pointC(a.pointC){}
    
    U4DTriangle& U4DTriangle::operator=(const U4DTriangle& a){
        
        pointA=a.pointA;
        pointB=a.pointB;
        pointC=a.pointC;
        
        return *this;
    }
    
    bool U4DTriangle::operator==(const U4DTriangle& a){
        
        return (pointA==a.pointA && pointB==a.pointB && pointC==a.pointC);
    }
    
    bool U4DTriangle::operator!=(const U4DTriangle& a){
        
        return (pointA!=a.pointA || pointB!=a.pointB || pointC!=a.pointC);
    
    }


    U4DPoint3n U4DTriangle::closestPointOnTriangleToPoint(U4DPoint3n& uPoint){
        
        //check if p in vertex region outside A
        
        U4DVector3n ab=pointA-pointB;
        U4DVector3n ac=pointA-pointC;
        U4DVector3n ap=pointA-uPoint;
        
        float d1=ab.dot(ap);
        float d2=ac.dot(ap);
        
        if (d1<=0.0f && d2<=0.0f) return pointA; //barycentric coordinates (1,0,0)
        
        //check if P in vertex region outside B
        
        U4DVector3n bp=pointB-uPoint;
        float d3=ab.dot(bp);
        float d4=ac.dot(bp);
        
        if (d3>=0.0f && d4<=d3) return pointB; //barycentric coordinates (0,1,0)
        
        
        //check if P in edge region of AB, if so return projection of P onto AB
        
        float vc=d1*d4-d3*d2;
        
        if (vc<=0.0f && d1>=0.0f && d3<=0.0f) {
            
            float v=d1/(d1-d3);
            
            U4DPoint3n abPoint;
            abPoint.convertVectorToPoint(ab);
            
            return pointA+abPoint*v; //barycentric coordinates (1-v,v,0)
            
        }
        
        //check if p in vertex region outside C
        
        U4DVector3n cp=pointC-uPoint;
        float d5=ab.dot(cp);
        float d6=ac.dot(cp);
        
        if (d6>=0.0f && d5<=d6) return pointC; //barycentric coordinates (0,0,1)
        
        //check if P in edge region of AC, if so return projection of P onto AC
        
        float vb=d5*d2-d1*d6;
        
        if (vb<=0.0f && d2>=0.0f && d6<=0.0f) {
            
            float w=d2/(d2-d6);
            
            U4DPoint3n acPoint;
            acPoint.convertVectorToPoint(ac);
            
            return pointA+acPoint*w;  //barycentric coordinates (1-w,0,w)
            
        }
        
        //check if p in edge region of BC, if so return projection of P onto BC
        float va=d3*d6-d5*d4;
        
        if (va<=0.0f && (d4-d3)>=0.0f && (d5-d6)>=0.0f) {
            float w=(d4-d3)/((d4-d3)+(d5-d6));
            
            U4DPoint3n bcPoint;
            U4DVector3n bcVector=pointB-pointC;
            
            bcPoint.convertVectorToPoint(bcVector);
            
            return pointB+bcPoint*w; //barycentric coordinates (0,1-w,w)
        }
        
        
        //P inside face region, compute Q through its barycentric coordinates (u,v,w)
        
        U4DNumerical comparison;
        
        float denom=0.0;
        
        if (!comparison.areEqual(va+vb+vc, 0.0, U4DEngine::zeroEpsilon)) {
            denom=1.0f/(va+vb+vc);
        }
        
        float v=vb*denom;
        float w=vc*denom;
        
        U4DPoint3n abPoint;
        U4DPoint3n acPoint;
        
        abPoint.convertVectorToPoint(ab);
        acPoint.convertVectorToPoint(ac);
        
        return pointA+abPoint*v + acPoint*w;
        
    }


    bool U4DTriangle::isPointOnTriangle(U4DPoint3n& uPoint){
        
        U4DNumerical comparison;
        
        U4DVector3n a=pointA-uPoint;
        U4DVector3n b=pointB-uPoint;
        U4DVector3n c=pointC-uPoint;
        
        U4DVector3n u=b.cross(c);
        U4DVector3n v=c.cross(a);
        
        float uv=u.dot(v);
        
        if (comparison.areEqual(uv, 0.0, U4DEngine::zeroEpsilon)) {
            uv=0.0;
        }
        
        if (uv<0.0f) return 0;
        
        U4DVector3n w=a.cross(b);
        float uw=u.dot(w);
        
        if (comparison.areEqual(uw, 0.0, U4DEngine::zeroEpsilon)) {
            uw=0.0;
        }
        
        if(uw<0.0f) return 0;
        
        
        return 1;
        
    }
    
    void U4DTriangle::getBarycentricCoordinatesOfPoint(U4DPoint3n& uPoint, float& baryCoordinateU, float& baryCoordinateV, float& baryCoordinateW){
        
        U4DVector3n v0=pointA-pointB;
        U4DVector3n v1=pointA-pointC;
        U4DVector3n v2=pointA-uPoint;
        
        float d00=v0.dot(v0);
        float d01=v0.dot(v1);
        float d11=v1.dot(v1);
        float d20=v2.dot(v0);
        float d21=v2.dot(v1);
        
        float denom=d00*d11-d01*d01;
        
        U4DNumerical comparison;
        
        if (!comparison.areEqual(denom, 0.0, U4DEngine::zeroEpsilon)) {
            
            baryCoordinateV=(d11*d20-d01*d21)/denom;
            baryCoordinateW=(d00*d21-d01*d20)/denom;
            baryCoordinateU=1.0f-baryCoordinateV-baryCoordinateW;
            
        }
        
    }
    
    U4DVector3n U4DTriangle::getTriangleNormal(){
        
        return (pointA-pointB).cross(pointA-pointC);
    }
    
    
    U4DPoint3n U4DTriangle::getCentroid(){
        
        U4DPoint3n centroid((pointA.x+pointB.x+pointC.x)/3.0,(pointA.y+pointB.y+pointC.y)/3.0,(pointA.z+pointB.z+pointC.z)/3.0);
        
        return centroid;
        
    }
    
    U4DTriangle U4DTriangle::projectTriangleOntoPlane(U4DPlane& uPlane){
        
        U4DPoint3n projectedPointA=uPlane.closestPointToPlane(pointA);
        U4DPoint3n projectedPointB=uPlane.closestPointToPlane(pointB);
        U4DPoint3n projectedPointC=uPlane.closestPointToPlane(pointC);
        
        U4DTriangle projectedTriangle(projectedPointA,projectedPointB,projectedPointC);
        
        return projectedTriangle;
        
    }
    
    float U4DTriangle::distanceToPlane(U4DPlane& uPlane){
        
        float pointADistance=uPlane.magnitudeOfPointToPlane(pointA);
        float pointBDistance=uPlane.magnitudeOfPointToPlane(pointB);
        float pointCDistance=uPlane.magnitudeOfPointToPlane(pointC);
        
        float minDistace=std::min(pointADistance, pointBDistance);
        minDistace=std::min(pointCDistance,minDistace);
        
        return minDistace;
    }
    
    float U4DTriangle::distanceSquareToPlane(U4DPlane& uPlane){
        
        float pointADistance=uPlane.magnitudeSquareOfPointToPlane(pointA);
        float pointBDistance=uPlane.magnitudeSquareOfPointToPlane(pointB);
        float pointCDistance=uPlane.magnitudeSquareOfPointToPlane(pointC);
        
        float minDistace=std::min(pointADistance, pointBDistance);
        minDistace=std::min(pointCDistance,minDistace);
        
        return minDistace;
    }
    
    float U4DTriangle::centroidDistanceToPlane(U4DPlane& uPlane){
        
        U4DPoint3n triangleCentroid=getCentroid();
        
        return fabs(uPlane.magnitudeOfPointToPlane(triangleCentroid));
        
    }
    
    float U4DTriangle::centroidSquareDistanceToPlane(U4DPlane& uPlane){
     
        U4DPoint3n triangleCentroid=getCentroid();
        
        return fabs(uPlane.magnitudeSquareOfPointToPlane(triangleCentroid));
        
    }
    
    bool U4DTriangle::isValid(){
        
        float ab=(pointA-pointB).magnitude();
        float ac=(pointA-pointC).magnitude();
        float bc=(pointB-pointC).magnitude();
        
        if ((ab+ac>bc) && (ab+bc>ac)&&(ac+bc>ab)) {
            return true;
        }else{
            return false;
        }
        
    }
    
    std::vector<U4DSegment> U4DTriangle::getSegments(){
        
        U4DSegment segmentAB=U4DSegment(pointA,pointB);
        U4DSegment segmentBC=U4DSegment(pointB,pointC);
        U4DSegment segmentCA=U4DSegment(pointC,pointA);
        
        std::vector<U4DSegment> segments{segmentAB,segmentBC,segmentCA};
        
        return segments;
    }
    
    void U4DTriangle::show(){
        
        std::cout<<"Point A: "<<std::endl;
        pointA.show();
        std::cout<<"Point B: "<<std::endl;
        pointB.show();
        std::cout<<"Point C: "<<std::endl;
        pointC.show();
        
        U4DVector3n normal=getTriangleNormal();
        
        normal.show("Normal");
        
        if (isValid()) {
            std::cout<<"Triangle is Valid"<<std::endl;
        }else{
            std::cout<<"Triangle is not valid"<<std::endl;
        }
        
    }
    
}
