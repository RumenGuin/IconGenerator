//
//  IconViewModel.swift
//  IconGenerator
//
//  Created by RUMEN GUIN on 29/01/22.
//

import Foundation
import SwiftUI

class IconViewModel: ObservableObject {
    
    //MARK: Selected Image For Icon
    @Published var pickedImage: NSImage?
    
    //MARK: Loading and Alert
    @Published var isGenerating: Bool = false
    @Published var alertMsg: String = ""
    @Published var showAlert: Bool = false    
    
    //MARK: Icon Set Image Sizes
    @Published var iconSizes: [Int] = [
    //these are the sizes required for appIcon set, you can find this on appIcon in the assets catalogue
        20,60,58,87,80,120,180,40,29,76,152,167,1024,16,32,64,128,256,512,1024
    ]
    
    //MARK: Picking Image(from Finder) using NSOpen Panel
    func PickImage() {
        let panel = NSOpenPanel() //A panel that prompts/say the user to select a file to open.
        panel.title = "Choose a Picture"
        panel.showsResizeIndicator = true
        panel.showsHiddenFiles = false
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image, .png, .jpeg]
        
        
        //.runModal -> Displays the panel and begins its event loop with the current working (or last-selected) directory as the default starting point. Returns NSFileHandlingPanelOKButton (if the user clicks the OK button)
        if panel.runModal() == .OK {
            
            if let result = panel.url?.path {
                
                let image = NSImage(contentsOf: URL(fileURLWithPath: result))
                self.pickedImage = image
                
            }
            else {
                //MARK: Error
            }
        }
    }
    
    
    func generateIconSet() {
        //MARK: Steps
        //1. Asking user where to store icons -> folderSelector()
        folderSelector { folderURL in
            
            //2. Creating AppIcon.appiconset folder in it
            let modifierURL = folderURL.appendingPathComponent("AppIcon.appiconset")
            
            self.isGenerating = true
            
            //Doing in Thread
            // .userInteractive -> The quality-of-service class for user-interactive tasks, such as animations, event handling, or updating your app's user interface.
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    
                    
                    let manager = FileManager.default
                    try manager.createDirectory(at: modifierURL, withIntermediateDirectories: true, attributes: [:])
                    
                    //3. Writing Contents.json file inside the folder -> writeContentsFile()
                    self.writeContentsFile(folderURL: modifierURL.appendingPathComponent("Contents.json"))
                    
                    //4. Generating Icon set and writing inside the folder
                    if let pickedImage = self.pickedImage {
                        self.iconSizes.forEach { size in
                            
                            //CGSize -> A structure that contains width and height values.
                            //CGFloat -> The basic type for floating-point scalar values in Core Graphics
                            let imageSize = CGSize(width: CGFloat(size), height: CGFloat(size))
                            //so each image will be like 20.png, 32.png...
                            let imageURL = modifierURL.appendingPathComponent("\(size).png")
                            
                            pickedImage
                                .resizeImage(size: imageSize)
                                .writeImage(to: imageURL)
                            
                        }
                        //main thread
                        DispatchQueue.main.async {
                            self.isGenerating = false
                            //Saved Alert
                            self.alertMsg = "Generated Successfully!"
                            self.showAlert.toggle()
                        }
                    }
                    
                }catch {
                    //error
                    print(error.localizedDescription)
                    DispatchQueue.main.async { //main thread
                        self.isGenerating = false
                    }
                }
            }
        }
        
    }
    
    //MARK: Writing Contents.json
    func writeContentsFile(folderURL: URL) {
        do {
            //Apple uses bundles to represent apps, frameworks, plug-ins, and many other specific types of content.
            //A representation of the code and resources stored in a bundle directory on disk. -> Bundle
            let bundle = Bundle.main.path(forResource: "Contents", ofType: "json") ?? ""
            let url = URL(fileURLWithPath: bundle)
            
            //.atomic -> An option to write data to an auxiliary/extra file first and then replace the original file with the auxiliary/extra file when the write completes.
            try Data(contentsOf: url).write(to: folderURL, options: .atomic)
            
        }catch {
            
        }
    }
    
        //MARK: Folder Selector using NSOpenPanel
    func folderSelector(completion: @escaping (URL) -> ()) {
        
        let panel = NSOpenPanel() //A panel that prompts/say the user to select a file to open.
        panel.title = "Choose a Folder"
        panel.showsResizeIndicator = true
        panel.showsHiddenFiles = false
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false //can't choose files, only folders
        panel.canChooseDirectories = true
        panel.allowedContentTypes = [.folder]
        
        
        //.runModal -> Displays the panel and begins its event loop with the current working (or last-selected) directory as the default starting point. Returns NSFileHandlingPanelOKButton (if the user clicks the OK button)
        if panel.runModal() == .OK {
            
            if let result = panel.url?.path {
                completion(URL(fileURLWithPath: result))
                
            }
            else {
                //MARK: Error
            }
        }
        
        
    }
    
}
