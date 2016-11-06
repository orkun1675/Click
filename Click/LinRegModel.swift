//
//  LinRegModel.swift
//  MachineLearning
//
//  Created by TUNA UYSAL on 01/04/15.
//  Copyright (c) 2015 TUNA UYSAL. All rights reserved.
//

import Foundation

class LinRegModel {
    
    var swiftArray : Array<Array<Double>>
    var rawMatrix : matrix = zeros((1,1))
    var inputPoints : matrix = zeros((1,1))
    var X : matrix
    var y : matrix
    var theta : matrix
    var m : Int
    var n : Int
    var alpha : Double
    var learnOnRunAlpha : Double
    var lambda : Double
    var means : Array<Double>
    var stds : Array<Double>
    let nPrev : Int = 4
    
    //blank init
    init() {
        self.swiftArray = [[], []]
        self.lambda = 1
        self.alpha = 1
        self.learnOnRunAlpha = alpha / 1000
        m = swiftArray.count
        n = 0
        
        means = []
        stds = []
        
        X = zeros((8,3))
        y = zeros((m,1))
        theta = zeros((n+1,1))
    }
    
    //use this only before training
    init(swiftArray : Array<Array<Double>>, alpha : Double, lambda : Double) {
        self.swiftArray = swiftArray
        self.lambda = lambda
        self.alpha = alpha
        self.learnOnRunAlpha = alpha / 1000
        m = swiftArray.count
        n = 0//swiftArray[0].count - 1
        
        means = []
        stds = []
        
        X = zeros((8,3))
        y = zeros((m,1))
        theta = zeros((n+1,1))
        rawMatrix = swift2matrix(swiftArray)
        
        //add X an extra ones column for the constant term in theta
        inputPoints = rawMatrix[0..<m,0..<swiftArray[0].count - 1]
        X = ones((m,1))//for now add ones
        y = rawMatrix["all",n].reshape((m,1))
        
        manageX()
        normalize()
    }
    
    //use this after, training with
    init(theta : Array<Double>, means : Array<Double>, stds : Array<Double>, alpha : Double, lambda : Double) {
        n = theta.count-1
        
        self.theta = asarray(theta).reshape((n+1,1))
        self.lambda = lambda
        self.alpha = alpha
        self.learnOnRunAlpha = alpha / 1000
        
        self.means = means
        self.stds = stds
        
        //these will not be used
        self.swiftArray = [[]]
        m = 1
        X = zeros((1,1))
        y = zeros((1,1))
    }
    
    //Takes the number of points (current and previous) to be considered as input
    func manageX() {
        var flatX : ndarray = X.T.flat
        var deltax : ndarray
        var deltay : ndarray
        var deltas : ndarray
        
        for i in 1...nPrev-1 {
            //adds the difference of distance between curPoint and nthPreviousPoint
            deltax = (inputPoints["all", 0] - inputPoints["all", 2*i])
            deltay = (inputPoints["all", 1] - inputPoints["all", 2*i+1])
            deltas = sqrt((deltax*deltax+deltay*deltay))
            
            flatX = concat(flatX, y: deltas)
            n += 1//added one more feature
        }
        
        //prepare features for each inputPoints values
        var points : Array<Array<Double>> = [[Double]](repeating: [0], count: (nPrev))
        var feature1 : Array<Double>  = [Double](repeating: 0, count: (m))
        var feature2 : Array<Double>  = [Double](repeating: 0, count: (m))
        var feature3 : Array<Double>  = [Double](repeating: 0, count: (m))
        var feature4 : Array<Double>  = [Double](repeating: 0, count: (m))
        for i in 0...m-1 { //has logic mistakes
            //prepare points
            for j in 0...nPrev-1 {
                points[j] = inputPoints[i, 2*j..<2*j+2].grid//check
            }
            
            //form features
            feature1[i] = getCOMMeanDist(points)
            feature2[i] = getFitR2(points)
            feature3[i] = getDispDot(points)
            feature4[i] = getCornDist(points)
        }
        
        flatX = concat(flatX, y: asarray(feature1))
        flatX = concat(flatX, y: asarray(feature2))
        flatX = concat(flatX, y: asarray(feature3))
        flatX = concat(flatX, y: asarray(feature4))
        n += 4//added 4 more features
        
        X = (flatX.reshape((n+1,m))).T//reshape X to refer during the following loop
        var feature : ndarray
        flatX = X.T.flat
        
        for i in 1...n {
            feature = X["all",i]
            flatX = concat(flatX, y: (feature*feature))
        }
        n = 2*n//now there is one more parameter for every old parameter
        X = (flatX.reshape((n+1,m))).T
        theta = zeros((n+1,1))//theta needs to have more parameters
        means = [Double](repeating: 0, count: (n+1))
        stds = [Double](repeating: 0, count: (n+1))
    }
    
    func normalize() {
        var feature : ndarray
        
        var normalized : Array<Double> = ones(m).grid //the constant terms won't be normalized
        
        feature = y.flat
        //the first element of means and stds are of the y values
        means[0] = mean(feature)
        stds[0] = std(feature)
        var yNormal = ((feature - means[0])/stds[0]).reshape((m,1))
        
        //the rest are of the X features
        for i in 1...n {
            feature = X["all", i]
            means[i] = mean(feature)
            stds[i] = std(feature)
            feature = (feature - means[i])/stds[i]
            normalized += feature.grid
        }
        var XNormal = asarray(normalized).reshape((n+1,m)).T
        
        X = XNormal
        y = yNormal
    }
    
    func train() { //run the algorithm to get parameters theta
        var oldCost : Double = inf
        var curCost : Double = getCost()
        while (abs(oldCost-curCost) > 0.0000001) {
            theta = theta - alpha * gradient()
            oldCost = curCost
            curCost = getCost()
        }
    }
    
    func learnOnRun(_ newData : Array<Array<Double>>) {
        //new n and m
        var nn : Int = newData[0].count-1
        var mn : Int = newData.count
        
        var rawMat : matrix = swift2matrix(newData)
        var yn : matrix = rawMat["all",nn].reshape((mn,1))
        
        //extract points (current and previous(es))
        var preInput : Array<Array<Double>> = [[Double]](repeating: [0], count: (nPrev))
        
        //begin online learning
        for i in 0...mn-1 {
            //form preInput ready to use points2input
            for j in 0...nPrev-1 {
                preInput[j] = [newData[i][2*j], newData[i][2*j+1]]
            }
            var yval : Double = yn[i,"all"][0]
            //form the input
            var input : ndarray = points2input(preInput)
            //update theta for every new training example there is
            var factor = concat(zeros(1), y: ones(n)).reshape((n+1,1))
            theta = theta - learnOnRunAlpha*(((sum(theta.flat * input) - yval)*input).reshape((n+1,1)) + factor * lambda * theta)
        }
    }
    
    //returns an Array<Double> of points ready to be used (values between 0 and 1)
    func getPoints(_ nPoint : Int) -> Array<Array<Double>> {
        //generate a random point to begin with
        var point : Array<Double> = [0.0, 0.0]
        var points : Array<Array<Double>> = [[Double]](repeating: [0], count: (nPoint))
        
        for i in 0...nPrev-2 {
            points[i] = [Double(arc4random()%1000)/1000.0, Double(arc4random()%1000)/1000.0]
        }
        
        //add that point to the beginning
        var prevPoints : Array<Array<Double>>
        //generate points that maximize time given the previous point
        for i in nPrev-1...nPoint-1 {
            if (i-1) % 4 == 0 {
                point = [Double(arc4random()%1000)/1000.0, Double(arc4random()%1000)/1000.0]
            } else {
                prevPoints = [[Double]](repeating: [0], count: (nPrev-1))
                for j in 0...nPrev-2 {
                    prevPoints[j] = points[i-nPrev+1+j]
                }
                point = maximizeTime(prevPoints)
            }
            points[i] = point
            
        }
        return points
    }
    
    //input raw data (not normalized)
    func maximizeTime(_ prevPoints : Array<Array<Double>>) -> Array<Double> {
        //point to be tried
        var point : Array<Double> = [0.0, 0.0]
        //input to be tried
        var input :ndarray
        
        var prevPoint : Array<Double> = prevPoints[0]
        
        //xcron an ycorn to find the farthest corner
        //rounded to 0 means one side and 1 the other
        var xcorn = pow(round(prevPoint[0]) - 1,2)
        var ycorn = pow(round(prevPoint[1]) - 1,2)
        
        //distance to the farthest corner
        var maxDist : Double = sqrt(pow((prevPoint[0]-xcorn),2)+pow((prevPoint[1]-ycorn),2))
        var tOld : Double = 0
        var tCur : Double = -9999
        var tMax : Double = -9999
        //variable to be returned
        var pointMax : Array<Double> = [0.0, 0.0]
        
        //radius of the circle to draw points from
        var rad : Double
        //the angle on the circle
        var ang : Double
        
        //try 20 radiuses with equal spacing
        for i in 10...20 {
            rad = i*maxDist/20.0
            //initialize a random starting angle
            ang = tau * Double(arc4random()%1000)/1000.0
            //try i points (this way depends on the radius of the circle)
            for j in 1...i {
                ang = (ang + j*tau/Double(i)).truncatingRemainder(dividingBy: tau)
                point = [prevPoint[0]+rad*cos(ang), prevPoint[1]+rad*sin(ang)]
                //if the point generated is in bounds
                if (0<point[0]) && (point[0]<1) && (0<point[1]) && (point[1]<1) {
                    input = points2input([point]+prevPoints)
                    //calculate tCur
                    tOld = tCur
                    tCur = sum(theta.flat * input)
                    //compare with tMax
                    if tCur > tMax {
                        tMax = tCur
                        pointMax = point
                    }
                }
            }
        }
        return pointMax
    }
    
    //takes points and returns the normalized input for those points
    func points2input(_ points : Array<Array<Double>>) -> ndarray {
        
        var inputArray : Array<Double> = [1.0]
        var deltas : Double
        
        var input : ndarray = asarray(inputArray)
        
        //add difference between curPoint and prevPoints features
        for i in 1...nPrev-1 {
            var d1 = pow((points[0][0]-points[i][0]), 2)
            var d2 = pow((points[0][1]-points[i][1]), 2)
            deltas = sqrt(d1 + d2)
            input = concat(input, y: asarray([deltas]))
        }
        
        //prepare new features
        var features : Array<Double> = [getCOMMeanDist(points)]
        features += [getFitR2(points)]
        features += [getDispDot(points)]
        features += [getCornDist(points)]
        input = concat(input, y: asarray(features))
        
        //add the features
        input = concat(input, y: input[1..<input.n]^2)
        
        //now normalize it
        //turn the means into an array but don't forget that means[0] is of the y value
        var ameans = asarray(means)
        //same for stds
        var astds = asarray(stds)
        
        //normalizing the input
        input = (input - ameans) / astds
        //reset the constant X0 as 1
        input[0] = 1.0
        
        return input
    }
    
    func getCOMMeanDist(_ points : Array<Array<Double>>) -> Double {
        var meanDist : Double = 0
        
        var l : matrix = ones((points.count,1))
        
        var pointsMat : matrix = swift2matrix(points)
        var x : matrix = pointsMat["all", 0].reshape((points.count,1))
        var y : matrix = pointsMat["all", 1].reshape((points.count,1))
        
        var M : matrix = l *! ((l.T *! l).I *! l.T)
        
        var yDemeaned2 : matrix = pow((y - (M *! y)),2)
        var xDemeaned2 : matrix = pow((x - (M *! x)),2)
        var dist : matrix = sqrt(xDemeaned2 + yDemeaned2)
        
        meanDist = sum(dist.flat) / points.count
        
        return meanDist
    }
    
    func getFitR2(_ points : Array<Array<Double>>) -> Double {
        var R2 : Double = 0
        
        var pointsMat : matrix = swift2matrix(points)
        var x : matrix = (concat(ones(points.count), y: pointsMat["all", 0]).reshape((2,points.count))).T
        var y : matrix = pointsMat["all", 1].reshape((points.count,1))
        
        var l : matrix = ones((points.count,1))
        var M : matrix = l *! ((l.T *! l).I *! l.T)
        var H : matrix = x *! ((x.T *! x).I *! x.T)
        
        var errors : matrix = y - (H *! y)
        var yDemeaned : matrix = y - (M *! y)
        
        var sse : Double = sum((errors.T *! errors).flat)
        var ssr : Double = sum((yDemeaned.T *! yDemeaned).flat)
        
        R2 = 1.0 - sse/ssr
        return R2
    }
    
    func getDispDot(_ points : Array<Array<Double>>) -> Double {
        var dotPro : Double = 0
        
        var p1 : ndarray = asarray(points[0])
        var p2 : ndarray = asarray(points[1])
        var p3 : ndarray = asarray(points[2])
        
        var disp1 :ndarray = p1 - p2
        var disp2 :ndarray = p2 - p3
        
        dotPro = sum((disp1/norm(disp1)) * (disp2/norm(disp2)))
        return dotPro
    }
    
    func getCornDist(_ points : Array<Array<Double>>) -> Double {
        var cornDist : Double = 0
        
        var point : Array<Double> = points[0]
        var corn : Array<Double> = [round(point[0]), round(point[1])]
        
        cornDist = sqrt(pow((point[0]-corn[0]),2) + pow((point[1]-corn[1]),2))
        
        return cornDist
    }
    
    func plotXYTime() {
        var input : ndarray
        var prevPoint = [10.0, 10.0]
        var point = [0.0, 0.0]
        var time : Double
        for y in 1...100 {
            for x in 1...100 {
                point = [Double(x)/5.0-5.0, Double(y)/5.0-5.0]
                input = asarray([1.0]+point+prevPoint)
                input = concat(input, y: asarray([point[0]-prevPoint[0]]+[point[1]-prevPoint[1]]))
                input = concat(input, y: input[1..<7]^2)
                time = sum(theta.flat * input)
            }
        }
    }
    
    func getCost() -> Double {
        var dif = hypo() - y
        var cost = ((dif *! dif.T)/(2*m))[0,0] //actually is a single value
        return cost
    }
    
    func gradient() -> matrix {
        var factor = concat(zeros(1), y: ones(n)).reshape((n+1,1))
        var grad = (X.T *! (hypo()-y)) * (1/m) + (lambda/m)*theta*factor
        return grad
    }
    
    func hypo() -> matrix {
        return X *! theta
    }
    
    func swift2matrix(_ swArray : Array<Array<Double>>) -> matrix {
        var flatArray : Array<Double> = []
        var finMatrix : matrix
        
        let nRow = swArray.count
        let nCol = swArray[0].count
        
        for i in 0...(swArray.count-1) {
            flatArray += swArray[i]
        }
        finMatrix = asarray(flatArray).reshape((nRow,nCol))
        return finMatrix
    }
    
    //call and store these before exiting the program to use it again afterwards
    func getTheta() -> Array<Double> {
        let thetaArray : Array<Double> = theta.flat.grid
        return thetaArray
    }
    func getMeans() -> Array<Double> {
        return means
    }
    func getStds() -> Array<Double> {
        return stds
    }
    func getAlpha() -> Double {
        return alpha
    }
    func getLambda() -> Double {
        return lambda
    }
    
}
