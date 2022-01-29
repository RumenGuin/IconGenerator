//
//  NSImage.swift
//  IconGenerator
//
//  Created by RUMEN GUIN on 29/01/22.
//

import Foundation
import SwiftUI

//MARK: Extending NSImage to resize the Image with new size

extension NSImage {
    
    func resizeImage(size: CGSize) -> NSImage {
        
    //Since macBook displays are retina display so its scaling factor will be @2x or @4x so reducing that while resizing the image
        //Reducing Scaling Factor
        // NSScreen -> An object that describes the attributes of a computer’s monitor or screen.
        // .main -> Returns the screen object containing the window with the keyboard focus.
        // .backingScaleFactor -> The backing store pixel scale factor for the screen.
        let scale = NSScreen.main?.backingScaleFactor ?? 1
        let newSize = CGSize(width: size.width / scale, height: size.height / scale)
        let newImage = NSImage(size: newSize)
        newImage.lockFocus() //Prepares the image to receive drawing commands.
        
        //Drawing Image
        //.draw -> Draws the image in the specified rectangle.
        //NSRect -> A rectangle.
        self.draw(in: NSRect(origin: .zero, size: newSize))
        
        newImage.unlockFocus() //This message must be sent after a successful lockFocus()
        
        return newImage
        
    }
    
    //MARK: Writing Resized image as PNG
    //converting as PNG and saving it to the selected folder
    func writeImage(to: URL) {
        
        // Converting as PNG
        // Tag Image File Format - TIFF
        //a bitmap is an array of binary data representing the values of pixels in an image or display.
        guard
            let data = tiffRepresentation, // A data object containing TIFF data for all of the image representations in the image.
            let representation = NSBitmapImageRep(data: data), // An object that renders an image from bitmap data.
            let pngData = representation.representation(using: .png, properties: [:])
        else {return}
        
        //to -> to URL
        //atomic -> An option to write data to an auxiliary/extra file first and then replace the original file with the auxiliary/extra file when the write completes.
        try? pngData.write(to: to, options: .atomic)
    }
    
}
