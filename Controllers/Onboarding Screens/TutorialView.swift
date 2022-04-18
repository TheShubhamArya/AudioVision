//
//  SwiftUIView.swift
//  
//
//  Created by Shubham Arya on 4/14/22.
//

import SwiftUI

struct TutorialView: View {
    @State private var didTapNext = 0
    @State var prevValue = 0
    var body: some View {
        VStack {
            Text("Here are some commands you can choose to say while using the app. You can choose to use them or just use the user interface.")
                .padding()
            
            if didTapNext == 0 {
                CommandCell(image: "camera",headline: "\"Open Camera\"",subtitle: "This command opens the camera for you to take images", prevValue: prevValue, didTapNext: didTapNext)
                 
            } else if didTapNext == 1 {
                CommandCell(image: "camera.metering.partial",headline: "\"Take Picture\"",subtitle: "This command takes a picture when the camera is open. You can use this command to take multiple pictures.",prevValue: prevValue, didTapNext: didTapNext)
            } else if didTapNext == 2 {
                CommandCell(image: "eye.fill",headline: "\"Done\"",subtitle: "This will remove the camera view from the screen and process the pictures for text.", prevValue: prevValue, didTapNext: didTapNext)
            } else if didTapNext == 3 {
                CommandCell(image: "speaker.wave.2.fill",headline: "\"Read to Me\"",subtitle: "This commands reads the processed text to you on your speaker. Make sure to have volume up.", prevValue: prevValue, didTapNext: didTapNext)
            } else if didTapNext == 4 {
                CommandCell(image: "photo.fill",headline: "\"Open Photo Library\"",subtitle: "This command opens the photo library for you to select image from your photo library.", prevValue: prevValue, didTapNext: didTapNext)
            } else if didTapNext == 5 {
                CommandCell(image: "folder.fill",headline: "\"Read from Files\"",subtitle: "This command opens the files app for you to select a file that you want to be read to you.", prevValue: prevValue, didTapNext: didTapNext)
            } else if didTapNext == 6 {
                CommandCell(image: "video.fill",headline: "\"Open Live Detection\"",subtitle: "This command opens the live text detection screen so you can detect text in real time.", prevValue: prevValue, didTapNext: didTapNext)
            }  else  {
                CommandCell(color: .green, image: "checkmark.circle.fill",headline: "You're all set!",subtitle: "Let's find text in images.", prevValue: prevValue, didTapNext: didTapNext)
                    .transition(.scale)
            }
            
            if didTapNext < 7 {
                HStack  {

                    Button {
                        withAnimation {
                            prevValue = didTapNext
                            didTapNext -= 1
                            if didTapNext < 0 {
                                didTapNext = 0
                            }
                        }
                        
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                    }
                    .padding()
                    Text("\(didTapNext + 1) / **8** ")
                        .padding()

                    Button {
                        withAnimation {
                            prevValue = didTapNext
                            didTapNext += 1
                        }
                        
                    } label: {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.forward")
                        }
                    }
                    .padding()
                }
            } else  {
                Button {
                    if let topController = UIApplication.kTopViewController() {
                        topController.dismiss(animated: true)
                    }
                } label: {
                    HStack {
                        Text("Let's go")
                    }
                }
                .padding()
            }
            
            Spacer()
                .navigationTitle("Speech commands")
                .toolbar {
                    Button("Skip") {
                        if let topController = UIApplication.kTopViewController() {
                            topController.dismiss(animated: true)
                        }
                    }
                }
        }
    }
    
    struct CommandCell: View {
        var color : Color = .blue
        let image: String
        let headline: String
        let subtitle: String
        let prevValue : Int
        let  didTapNext :Int
        
        var body: some View {
            VStack(alignment: .center) {
                Image(systemName: image)
                    .frame(width: 100, height: 100)
                    .font(.system(size: 70,
                                  weight: .bold,
                                  design: .default))
                    .foregroundColor(color)
                    .padding()
                Text(headline)
                    .font(.system(size: 22,
                                  weight: .bold,
                                  design: .default))
                    .padding(.bottom, 10)
                Text(subtitle)
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 300, alignment: .center)
            .transition(prevValue < didTapNext ? .frontslide : .backslide)
            .padding()
                
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
    }
}

extension AnyTransition {
    
    static var backslide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading))}
    
    static var frontslide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .leading),
            removal: .move(edge: .trailing))}
}
