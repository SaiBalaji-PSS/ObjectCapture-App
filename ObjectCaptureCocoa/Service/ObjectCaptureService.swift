//
//  ObjectCaptureService.swift
//  ObjectCaptureCocoa
//
//  Created by Sai Balaji on 19/09/22.
//

import Foundation
import RealityKit

class ObjectCaptureService{
    static var Shared = ObjectCaptureService()
    
    func beginScan(inputURL: String,outputURL: String,onCompletion:@escaping(Error?,PhotogrammetrySession?)->(Void)){
        let inputFolderURL =  URL(fileURLWithPath: inputURL,isDirectory: true)
        let outputURL = URL(fileURLWithPath: outputURL)
        
        let session = try! PhotogrammetrySession(input: inputFolderURL, configuration: PhotogrammetrySession.Configuration())
        let request = PhotogrammetrySession.Request.modelFile(url: outputURL, detail: .medium)
        do{
            try  session.process(requests: [request])
            onCompletion(nil,session)
        }
        catch{
            onCompletion(error,nil)
        }
        
}
}
