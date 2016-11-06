//
//  AIManager.swift
//  Click
//
//  Created by Orkun Duman on 03/05/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import Foundation

class AIManager {
    
    let defaultAlpha = 0.01
    let defaultLambda = 0.5
    
    var model : LinRegModel
    
    init(loadFromMemory: Bool) {
        if !loadFromMemory {
            model = LinRegModel()
            if let dotData = UserDefaults.standard.object(forKey: "GameData") as? Array<Array<Double>> {
                model = LinRegModel(swiftArray: dotData, alpha: defaultAlpha, lambda: defaultLambda)
                model.train()
                saveData()
            }
        } else {
            var alpha = defaultAlpha
            var lambda = defaultLambda
            var theta : Array<Double> = []
            var means : Array<Double> = []
            var stds : Array<Double> = []
            if let fetchAlpha = UserDefaults.standard.object(forKey: "ModelAlpha") as? Double {
                alpha = fetchAlpha
            }
            if let fetchLambda = UserDefaults.standard.object(forKey: "ModelLambda") as? Double {
                lambda = fetchLambda
            }
            if let fetchTheta = UserDefaults.standard.object(forKey: "ModelTheta") as? Array<Double> {
                theta = fetchTheta
            }
            if let fetchMeans = UserDefaults.standard.object(forKey: "ModelMeans") as? Array<Double> {
                means = fetchMeans
            }
            if let fetchStds = UserDefaults.standard.object(forKey: "ModelStds") as? Array<Double> {
                stds = fetchStds
            }
            model = LinRegModel(theta: theta, means: means, stds: stds, alpha: alpha, lambda: lambda)
        }
    }
    
    func saveData() {
        UserDefaults.standard.set(model.getAlpha(), forKey: "ModelAlpha")
        UserDefaults.standard.set(model.getLambda(), forKey: "ModelLambda")
        UserDefaults.standard.set(model.getTheta(), forKey: "ModelTheta")
        UserDefaults.standard.set(model.getMeans(), forKey: "ModelMeans")
        UserDefaults.standard.set(model.getStds(), forKey: "ModelStds")
    }
    
    func getPoints(_ source : GameScene, numOfPoints : Int) {
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            let data = self.model.getPoints(numOfPoints)
            DispatchQueue.main.async(execute: { () -> Void in
                source.upadateDotData(data)
            })
        })
    }
    
}
