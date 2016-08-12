//
//  llk.cpp
//  连连看
//
//  Created by lvjiaqi on 16/8/7.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

#include "llk.hpp"


#pragma mark - 构造和析构函数;

llk::llk(int _m ,int _n , int _t){
    m = _m;
    n = _n;
    t = _t;
    eleArr = new ele_p[m*n];
    for (int i=0 ;  i < m ; i++) {
        for (int j=0 ;  j < n ; j++) {
            eleArr[n*i+j] = new ele(i,j,0);
        }
    }
    currentCount = 0;
    initGame();
}

llk::~llk(){
    for (int i=0 ;  i < m ; i++) {
        for (int j=0 ;  j < n ; j++) {
            delete eleArr[n*i+j];
        }
    }
    
    emptyEle.clear();
    vector<int>(emptyEle).swap(emptyEle);
    
    delete [] eleArr;
}

#pragma mark - SearchAlgorithm

#pragma mark - 判断两点是否有直线通路
bool llk::isPath(ele_p s , ele_p d){
    if (s->x != s->x && s->y != d->y) {
        return false;
    }
    if (s->x == d->x) {
        int sI = s->y > d->y ? d->y : s->y;
        int eI = s->y < d->y ? d->y : s->y;
        for (int i = sI+1;  i < eI ; i++) {
            if ( getQ(s->x, i) != 0) {
                return false;
            }
        }
        return true;
    }else if(s->y == d->y){
        int sI = s->x > d->x ? d->x : s->x;
        int eI = s->x < d->x ? d->x : s->x;
        for (int i = sI+1;  i < eI ; i++) {
            if ( getQ(i, s->y) != 0) {
                return false;
            }
        }
        return true;
    }
    return false;
}

#pragma mark - 该点沿着某方向能拓展的距离
int llk::pathToIndex(ele_p e , int type){   // 1上 2右 3下 4左
    int index = 0;
    
    switch (type) {
        case 1:
            for (int i = e->x-1; i >= 0; i--) {
                
                if ( getQ(i, e->y) != 0 ) {
                    index = i+1;
                    break;
                }
                index = i;
            }
            break;
        case 2:
            for (int i = e->y+1; i < n; i++) {
                if ( getQ(e->x, i) != 0 ) {
                    index = i-1;
                    break;
                }
                index = i;
            }
            break;
        case 3:
            
            for (int i = e->x+1; i < m ; i++) {
                
                if ( getQ(i, e->y) != 0 ) {
                    index = i-1;
                    break;
                }
                index = i;
                
            }
            break;
        case 4:
            for (int i = e->y-1; i >= 0; i--) {
                if ( getQ(e->x, i) != 0 ) {
                    index = i+1;
                    break;
                }
                index = i;
            }
            break;
        default:
            break;
    }
    
    return index;
    
}

#pragma mark - 两点是否存在通路

list<int>* llk::hasPath(ele_p s , ele_p d ){
    
    list<int> *paths = NULL;
    
    if (s->q != d->q) return paths;
    if (s->x == d->x && s->y == d->y) return paths;
    
    /*if (s->x == d->x || s->y == d->y) {
        if(isPath(s, d)) {
            paths.push_back(getIndex(s));
            paths.push_back(getIndex(d));
            return paths;
        }
    }*/
    
    int sTop = pathToIndex(s, 1);
    int sButtom = pathToIndex(s, 3);
    int dTop = pathToIndex(d, 1);
    int dButtom = pathToIndex(d, 3);
    int top = sTop > dTop ? sTop : dTop;
    int buttom = sButtom < dButtom ? sButtom : dButtom;
    if (buttom >= top && searchPathByX(s, d, top, buttom,&paths)) return paths;
    
    int sLeft = pathToIndex(s, 4);
    int sRight = pathToIndex(s, 2);
    int dLeft = pathToIndex(d, 4);
    int dRight = pathToIndex(d, 2);
    int left = sLeft > dLeft ? sLeft : dLeft;
    int right = sRight < dRight ? sRight : dRight;
    if (left <= right && searchPathByY(s, d, left, right,&paths)) return paths;
    
    return paths;
}

#pragma mark - 两点拓展的两平行线上的两点是否有通路

bool llk::searchPathByY(ele_p s , ele_p e , int f , int b , list<int> **paths){
    
    list<int> *elePath = new list<int>;
    
    ele_p front ;
    ele_p back;
    if (s->y >= e->y) {
        front = e;
        back = s;
    }else{
        back = e;
        front = s;
    }
    int middle = 0;
    
    if (front->y >= f) {
        if (back->y <= b) {
            //search from middle of frontAndBack
            middle = (front->y+back->y)/2;
        }else{
            middle = front->y;
        }
    }else{
        if (back->y >= b) {
            // search from middle of frontAndBack
            middle = (f+b)/2;
        }else{
            // search from middle of back
            middle = back->y;
        }
    }
    
    int middleOffset = 0;
    while (middle+middleOffset <= b || middle-middleOffset>=f ) {
        if ( middle+middleOffset <= b && isPath(getEle(front->x, middle+middleOffset),getEle(back->x, middle+middleOffset)) ) {
            elePath->push_back(getIndex(getEle(front->x,middle+middleOffset)));
            elePath->push_back(getIndex(getEle(back->x,middle+middleOffset)));
            break;
        }
        if ( middle-middleOffset >=f && isPath(getEle(front->x, middle-middleOffset),getEle(back->x, middle-middleOffset)) ) {
            elePath->push_back(getIndex(getEle(front->x,middle-middleOffset)));
            elePath->push_back(getIndex(getEle(back->x,middle-middleOffset)));
            break;
        }
        middleOffset++;
    }
    if (elePath->empty()) {
        delete elePath;
        return false;
    }
    
    if (elePath->front() != getIndex(front)) {
        elePath->push_front(getIndex(front));
    }
    if (elePath->back() != getIndex(back)) {
        elePath->push_back(getIndex(back));
    }
    if (front != s) {
        elePath->reverse();
    }
    *paths = elePath;
    return true;
}


bool llk::searchPathByX(ele_p s , ele_p e , int f , int b , list<int> **paths){
    
    list<int> *elePath = new list<int>;
    
    ele_p front ;
    ele_p back;
    if (s->x >= e->x) {
        front = e;
        back = s;
    }else{
        back = e;
        front = s;
    }
    int middle = 0;
    
    if (front->x >= f) {
        
        if (back->x <= b) {
            //search from middle of frontAndBack
            middle = (front->x+back->x)/2;
            
        }else{
            middle = front->x;
        }
    }else{
        if (back->x >= b) {
            // search from middle of frontAndBack
            middle = (f+b)/2;
        }else{
            // search from middle of back
            middle = back->x;
        }
    }
    
    int middleOffset = 0;
    while (middle+middleOffset <= b || middle-middleOffset>=f ) {
        
        if ( middle+middleOffset <= b && isPath(getEle(middle+middleOffset, front->y),getEle(middle+middleOffset, back->y)) ) {
            
            elePath->push_back(getIndex(getEle(middle+middleOffset, front->y)));
            elePath->push_back(getIndex(getEle(middle+middleOffset, back->y)));
            
            break;
        }
        if ( middle-middleOffset >=f && isPath(getEle(middle-middleOffset, front->y),getEle(middle-middleOffset, back->y)) ) {
            
            elePath->push_back(getIndex(getEle(middle-middleOffset, front->y)));
            elePath->push_back(getIndex(getEle(middle-middleOffset, back->y)));
            break;
        }
        middleOffset++;
    }
    
    if (elePath->empty()) {
        
        delete elePath;
        return false;
    }
    
    if (elePath->front() != getIndex(front)) {
        elePath->push_front(getIndex(front));
    }
    if (elePath->back() != getIndex(back)) {
        elePath->push_back(getIndex(back));
    }
    if (front != s) {
        elePath->reverse();
    }
    *paths = elePath;
    return true;
    
}


#pragma mark - 开始检索

list<int> * llk::startCheck(ele_p s , ele_p e){
    
    list<int> *paths = NULL;
    if (s != NULL && e!=NULL ) {
        paths = hasPath(s, e);
        if(paths != NULL ){
            emptyEle.push_back(getIndex(s));
            emptyEle.push_back(getIndex(e));
            emptyQ.push_front(s->q);
            emptyQ.push_back(e->q);
            currentCount = currentCount-2;
            s->q = 0;
            e->q = 0;
            return paths;
        }
    }
    return paths;
}

#pragma mark - 在空白权的某两点随机产生权值

coupleEle* llk::generateCoupleEle(){
    
    if (emptyEle.size() == 0) {
         return NULL;
    }
    
    int len_2 = (int)emptyEle.size()/2;
    
    srand((unsigned)time(0) );
    int index = rand() % len_2 ;
    
    int s = 0;
    int e = 0;
    
    vector<int>::iterator l;
    l = emptyEle.begin() + index;
    s = *l;
    emptyEle.erase(l);
    
    index = rand() % len_2 ;
    l = l+index;
    e = *l;
    emptyEle.erase(l);

    eleArr[e]->q = emptyQ.front();
        emptyQ.pop_front();
    eleArr[s]->q = emptyQ.front();
        emptyQ.pop_front();
    
    currentCount = currentCount +2;
    
    return new coupleEle(s,e,eleArr[s]->q,eleArr[e]->q);
    
}


void llk::printEles(){
    
    for (int i = 0; i < m ; i++) {
        for (int j = 0; j < n ; j++) {
            printf("%d ",getQ(i, j));
        }
        printf("\n");
    }
    
}


#pragma mark - 初始化游戏

void llk::initGame(){
    
    
    int sum = (m-2)*(n-2);
    int sum_2 = sum/2;
    int tmps[sum] ;
    
    srand((int)time(0));
    
    int c = 0;
    for (int i = 0 ; i<sum_2; i++) {
        tmps[i] = i%(t+1);
        if (tmps[i] == 0) {
            emptyQ.push_back(t-c%t);
            emptyQ.push_front(t-c%t);
            c++;
        }
        tmps[i+sum_2] = tmps[i];
    }

    int index, tmp, ii=0;
    for (ii = 0; ii <sum; ii++)
    {
        index = rand() % (sum - ii) + ii;
        if (index != ii)
        {
            tmp = tmps[ii];
            tmps[ii] = tmps[index];
            tmps[index] = tmp;
        }
    }
    
    int swim = 0;
    for (int i = 1; i < m-1 ; i++) {
        for (int j = 1; j < n-1 ; j++) {
            if (tmps[swim] == 0) {
                emptyEle.push_back(i*n+j);
            }else{
                currentCount++;
            }
            setQ(i, j, tmps[swim++]);
        }
    }
    
}



