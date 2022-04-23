//
//  SwiftUIView.swift
//  
//
//  Created by Shubham Arya on 4/6/22.
//

import SwiftUI

struct WelcomeView: View {
    var fromHomeVC = false
    var body: some View {
        NavigationView{
            VStack(alignment: .leading) {
                ScrollView(.vertical) {
                    VStack {
                        HStack {
                            Text("Our eyesight is our most valued sense. Unfortunately, not everyone has this gift of sight. One [report](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwiC5rvr5JT3AhU8lmoFHS3lAm0QFnoECAsQAQ&url=https%3A%2F%2Fwww.orbis.org%2Fen%2Fnews%2F2021%2Fnew-global-blindness-data&usg=AOvVaw2IJZKfnyqX209DOWuxAFw2) reveals that there are **43 million people** living with blindness.")
                            Spacer()
                        }
                        
                        
                        HStack {
                            Text("To make this world a better place, it is important to make it accessible for everyone. AudioVision aims to assist visually impaired people by making them more aware of their surrounding through the power of other senses.")
                                .padding(.top)
                            Spacer()
                        }
                        
                        HStack {
                            Text("Here is how it is made possible.")
                                .fontWeight(.semibold)
                                .padding(.top)
                            Spacer()
                        }
                        
                        VStack {
                            FeatureCell(color: .blue, image: "mic.fill", headline: "Speech Recognizer", subtitle: "Use voice commands to get around the app without needing to see the screen. This is done so a visually impaired person can easily use the app with their voice.")
                            FeatureCell(color: .blue, image: "scissors", headline: "Image Stitching", subtitle: "Move camera from up to down very slowly over time. These frames are then stitched to create one image using Vision.")
                            FeatureCell(color: .blue, image: "eye.fill", headline: "Text detection", subtitle: "The image captured by you is used to detect text within the image using Computer Vision.")
                            FeatureCell(color: .blue, image: "textformat.abc", headline: "Natural Language Processing", subtitle: "The text in the image is checked for any spelling errors. A sentimental score for the text is also returned so user's know the emotions for the text.")
                            FeatureCell(color: .blue, image: "speaker.wave.2.fill", headline: "Speech Synthesizer", subtitle: "The corrected text is then read aloud through the device's speaker. ")
                        }.padding(.vertical)
                        
                        Text("Now that you know how AudioVision works, let's have a look at some of the speech commands you can use.")
                            .padding(.top)
                            .multilineTextAlignment(.leading)
                        
                        
                        Spacer()
                        
                    }
                    
                }.padding()
                
                if !fromHomeVC {
                    NavigationLink(destination: TutorialView()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10.0)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 55)
                                .foregroundColor(Color.blue)
                                .shadow(radius: 5)
                            Text("Learn speech commands")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                        }
                    }.padding()
                }
            }
            .navigationTitle("AudioVision")
        }.navigationViewStyle(.stack)
    }
    
    struct FeatureCell: View {
        let color: Color
        let image: String
        let headline: String
        let subtitle: String
        var body: some View {
            HStack(alignment: .center) {
                Image(systemName: image)
                    .frame(width: 40, height: 40)
                    .font(.system(size: 28,
                                  weight: .bold,
                                  design: .default))
                    .foregroundColor(color)
                    .padding(.trailing)
                VStack(alignment: .leading) {
                    Text(headline)
                        .font(.system(size: 22,
                                      weight: .bold,
                                      design: .default))
                        .padding(.bottom, 1)
                    Text(subtitle)
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                    
                }
                Spacer()
            }.padding(5)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}
