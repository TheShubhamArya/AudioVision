//
//  SwiftUIView.swift
//  
//
//  Created by Shubham Arya on 4/19/22.
//

import SwiftUI

struct LiveCameraHelpView: View {
    @State private var didTapNext = 0
    @State var prevValue = 0
    var body: some View {
        NavigationView{
            VStack {
                
                Text("Place camera close to text. Hold steady and keep the camera in **landscape** with camera on the top corner.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                
                
                Text("Here are some commands that are supported for the live text detection")
                    .padding()
                
                if didTapNext == 0 {
                    CommandCell(image: "play",headline: "\"Start\"",subtitle: "This command starts live text detection from your camera", prevValue: prevValue, didTapNext: didTapNext)
                    
                } else if didTapNext == 1 {
                    CommandCell(image: "pause",headline: "\"Stop\"",subtitle: "This command stops live text detection from your camera so you can focus on the text detected.",prevValue: prevValue, didTapNext: didTapNext)
                } else if didTapNext == 2 {
                    CommandCell(image: "speaker.wave.2.fill",headline: "\"Read to me\"",subtitle: "This reads the text detected by you. This command can be used only after you STOP live detection. This command reads text from the starting", prevValue: prevValue, didTapNext: didTapNext)
                } else if didTapNext == 3 {
                    CommandCell(image: "chevron.left.circle.fill",headline: "\"Quit Live Detection\"",subtitle: "This command quits live detection and takes you to the home screen", prevValue: prevValue, didTapNext: didTapNext)
                    
                } else if didTapNext == 4 {
                    CommandCell(color: .green, image: "checkmark.circle.fill",headline: "You're all set!",subtitle: "Let's find text in images.", prevValue: prevValue, didTapNext: didTapNext)
                        .transition(.scale)
                    
                }
                
                if didTapNext < 4 {
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
                        Text("\(didTapNext + 1) / **4** ")
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
                        Button("Done") {
                            if let topController = UIApplication.kTopViewController() {
                                topController.dismiss(animated: true)
                            }
                        }
                    }
            }
        }
        .navigationViewStyle(.stack)
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

struct LiveCameraHelpView_Previews: PreviewProvider {
    static var previews: some View {
        LiveCameraHelpView()
    }
}
