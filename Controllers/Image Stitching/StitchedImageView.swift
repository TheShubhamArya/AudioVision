//
//  SwiftUIView.swift
//  
//
//  Created by Shubham Arya on 4/22/22.
//

import SwiftUI

struct StitchedImageView: View {
    @StateObject public var viewModel = ViewModel()
    var stitchedImage  :  UIImage!
    var detectedText : String!
    var emojiImage : UIImage!
    @State var isSpeaking = false
    
    init(stitchedImage: UIImage, detectText: String, emojiImage: UIImage) {
        self.stitchedImage = stitchedImage
        self.detectedText =   detectText
        self.emojiImage = emojiImage
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        Image(uiImage: stitchedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 500)
                            .shadow(radius: 4)
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(detectedText.isEmpty ? "Nothing detected from image" : detectedText)
                                .font(.headline)
                                .fontWeight(.medium)
                                .padding()
                        }
                    }
                    .padding()
                }
                
                HStack {
                    Image(uiImage: emojiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    Button {
                        viewModel.text = detectedText
                        isSpeaking = !isSpeaking
                        viewModel.startSpeaking(with: detectedText)
                    } label: {
                        Image(systemName: isSpeaking ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 28,
                                          weight: .bold,
                                          design: .default))
                    }
                }
                .padding()
            }
            .navigationTitle("Stitched Image")
            .toolbar {
                Button {
                    if let topController = UIApplication.kTopViewController() {
                        topController.dismiss(animated: true)
                    }
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                }
            }
        }.navigationViewStyle(.stack)
            .onAppear() {
                viewModel.text = detectedText
            }
        
    }
}

struct StitchedImageView_Previews: PreviewProvider {
    static var previews: some View {
        StitchedImageView(stitchedImage: UIImage(systemName: "plus")!, detectText: "hello", emojiImage: UIImage(systemName: "plus")!)
    }
}
