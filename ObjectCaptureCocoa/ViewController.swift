//
//  ViewController.swift
//  ObjectCaptureCocoa
//
//  Created by Sai Balaji on 18/09/22.
//

import Cocoa
import RealityKit
import SceneKit

class ViewController: NSViewController {

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var StatusLabel: NSTextField!
    @IBOutlet weak var PreviewImageView: NSImageView!
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    private var FilePath = [String]()
    private var PreviewTimer: Timer?
    private var InputURL: String = ""
    private var OutputURL: String?
    private var OutputFilePath: String = ""
    private var Model: SCNScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ProgressBar.isIndeterminate = false
        
     
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
//MARK: - PICK IMAGE
    @IBAction func pickBtnPressed(_ sender: Any) {
        print("Pick")
        let dialog = NSOpenPanel()
        dialog.title = "Pick an image"
        dialog.showsResizeIndicator = true
        
        dialog.canChooseDirectories = true
        if(dialog.runModal() == NSApplication.ModalResponse.OK){
            
            self.InputURL = dialog.directoryURL!.path
            print(InputURL)
        }
    }
    
    
    
    @IBAction func outputLocationBtnPressed(_ sender: Any) {
        let dialog = NSOpenPanel()
        dialog.title = "Set the output location"
        dialog.showsResizeIndicator = true
        dialog.canChooseDirectories = true
        if(dialog.runModal() == NSApplication.ModalResponse.OK){
            OutputURL = dialog.directoryURL!.path
            //print(OutputURL)
        }
        
    }
    
    
    
    
    
    
    
    
    //MARK: - SCAN IMAGE
    @IBAction func scanBtnPressed(_ sender: Any) {
        
        let fm = try! FileManager.default.contentsOfDirectory(atPath: InputURL)
        for i in fm{
            self.FilePath.append(InputURL + "/" + i)
        }
        
        guard let OutputURL = OutputURL else {
            return
        }
        
        OutputFilePath =  OutputURL + "/" + "\(UUID().uuidString).usdz"
 
        ObjectCaptureService.Shared.beginScan(inputURL: InputURL, outputURL: OutputFilePath) { error, session in
            if let error = error {
                print(error)
            }
            if let session = session {
               
                do{

                    _ =   Task.init {
                        do{
                            for try await output in session.outputs{
                                switch output{
                                case .processingComplete:
                                    print("All requests Complete")
                                    self.StatusLabel.stringValue = "Processing Complete"
                                   // print(self.FilePath.first)
                                    self.PreviewTimer?.invalidate()
                                    self.load3DPreview()
                                    break
                                case .inputComplete:
                                    print("Input complelte")
                                    self.StatusLabel.stringValue = "Input Processing Complete"
                                    self.PreviewTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.showImageSlideShow), userInfo: self, repeats: true)
                                    break
                                    
                                case .processingCancelled:
                                    print("Processing cancelled")
                                    
                                    break
                                    
                                case .requestProgress(_, fractionComplete: let fraction):
                                    print("Progress\(fraction * 100)")
                                    self.ProgressBar.doubleValue = fraction * 100
                                    self.StatusLabel.stringValue = "Processing..."
                                    break
                                    
                                
                                
                                default:
                                    print("Default")
                                
                                }
                            }
                            
                            
                            
                          
                        }
                        
                        catch{
                            print("Error \(error.localizedDescription)")
                        }
                    }
            }

            }
        }
       

       
    }
    
    @objc func showImageSlideShow(){
        if let randomImagePath = FilePath.randomElement(){
            PreviewImageView.image = NSImage(byReferencingFile: randomImagePath)
        }
      
    }
    
    
    
    
    
    
    @IBAction func stopBtnPressed(_ sender: Any) {
        
        if let Model = Model {
            Model.rootNode.removeAllActions()
        }
    }
    
    
    
    
    
    
    
    
    
}


extension ViewController{
    func load3DPreview(){
      
 
        Model = try! SCNScene(url:URL(string:  OutputFilePath)!)
        
        Model!.rootNode.runAction((SCNAction.repeatForever(SCNAction.rotate(by: 0.5, around: SCNVector3(x: 0, y: 1, z: 0), duration: 1.0))))
        

        
        sceneView.allowsCameraControl = true
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .ambient
        lightNode.position = SCNVector3(x: 0, y: 10, z: 20)
        Model!.rootNode.addChildNode(lightNode)
        sceneView.scene = Model
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
