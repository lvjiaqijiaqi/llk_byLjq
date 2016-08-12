//
//  llk.hpp
//  连连看
//
//  Created by lvjiaqi on 16/8/7.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

#ifndef llk_hpp
#define llk_hpp

#include <stdio.h>
#include <iostream>
#include <vector>
#include <queue>
#include <list>
#include <string>
#include <math.h>

using namespace std;


struct coupleEle {
    int s;
    int e;
    int sQ;
    int eQ;
    coupleEle(int _s,int _e ,int _sQ , int _eQ ){
        s = _s;
        e = _e;
        sQ = _sQ;
        eQ = _eQ;
    }
};


struct ele {
    int x;
    int y;
    int q;
    ele(int _x , int _y ,int _q){
        x = _x;
        y = _y;
        q = _q;
    }
};
typedef ele* ele_p;


class llk{
private:
    
    unsigned int m;
    unsigned int n;
    unsigned int t;
    
    list<int> emptyQ;
    
    ele_p *eleArr;
    
    //一堆辅助功能函数;
    int emptyEleNum() const { return (int)emptyEle.size();}
    void setQ(int i , int j , int q){ eleArr[i*n+j]->q = q;}
    void clearQ(ele_p p){ p->q = 0;}
    ele_p getEle(int i , int j) const { return eleArr[i*n+j];}
    int getIndex(ele_p p) const {return p->x*n+p->y;}
    
    bool searchPathByY(ele_p s , ele_p e , int f , int b , list<int> **paths);
    bool searchPathByX(ele_p s , ele_p e , int f , int b , list<int> **paths);
    bool isPath(ele_p s , ele_p d);
    int pathToIndex(ele_p e , int type);
    list<int>* hasPath(ele_p s , ele_p d );
    
    
public:
    
    llk(int _m ,int _n , int _t);
    ~llk();
    
    vector<int> emptyEle;
    int currentCount;

    void printEles();
    void initGame();
    
    int getQ(int i , int j) const { return getEle(i, j)->q; }
    
    coupleEle* generateCoupleEle();
    list<int> * startCheckWithIndex(int p1 ,int p2){
        return startCheck(eleArr[p1], eleArr[p2]);
    }
    list<int> *startCheck(ele_p s , ele_p e);
};



#endif /* llk_hpp */
