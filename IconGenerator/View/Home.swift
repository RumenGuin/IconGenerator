//
//  Home.swift
//  IconGenerator
//
//  Created by RUMEN GUIN on 29/01/22.
//

import SwiftUI

struct Home: View {
    @StateObject private var iconModel: IconViewModel = IconViewModel()
    
    //MARK: Environment values for adopting UI for dark/light mode
    @Environment(\.self) var env
    var body: some View {
        VStack(spacing: 15) {
            if let image = iconModel.pickedImage {
                
                //MARK: Displaying Image with action and Generate Button
                Group {
                   displayImage(image: image)
                   generateButton
                }
            }
            else {
                //MARK: Add Button
                ZStack {
                    addButton
                    sizeNote
                }
            }
        }
        .frame(width: 400, height: 400)
        .buttonStyle(.plain)
        //MARK: Alert View
        .alert(iconModel.alertMsg,isPresented: $iconModel.showAlert) {
            
        }
        //MARK: Loading View
        .overlay(
            ZStack {
                if iconModel.isGenerating {
                    Color.black.opacity(0.25)
                    ProgressView()
                        .padding()
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                    //always light mode
                        .environment(\.colorScheme, .light)
                }
            }
        )
        .animation(.easeInOut, value: iconModel.isGenerating)
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

extension Home {
    private func displayImage(image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 250, height: 250)
            .clipped()
            .onTapGesture {
                iconModel.PickImage() //tap to go AppIcon.appiconset folder and drag to Assets folder of your project
            }
    }
    
    private var generateButton: some View {
        Button {
            iconModel.generateIconSet()
        } label: {
            Text("Generate Icon Set")
                .foregroundColor(env.colorScheme == .dark ? .black : .white)
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(.primary, in: RoundedRectangle(cornerRadius: 10))
        }
        .padding(.top, 10)
    }
    
    private var addButton: some View {
        Button {
            iconModel.PickImage()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(env.colorScheme == .dark ? .black : .white)
                .padding(15)
                .background(.primary, in: RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private var sizeNote: some View {
        //recommended size text
        Text("1024 X 1024 is recommended!")
            .font(.caption2)
            .foregroundColor(.gray)
            .padding(.bottom, 10)
            .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
