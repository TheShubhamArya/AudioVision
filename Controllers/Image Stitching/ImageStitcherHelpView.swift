//
//  SwiftUIView.swift
//  
//
//  Created by Shubham Arya on 4/23/22.
//

import SwiftUI

struct ImageStitcherHelpView: View {
    @State private var didTapNext = 0
    @State var prevValue = 0
    var body: some View {
        NavigationView{
            VStack {
                
                Text("Point at text and **slowly** move from **UP to DOWN**")
                    .padding()
                
                Text("This creates a long image to fit more text. Keep camera steady and keep orientation potrait for maximum detection.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                Text("Here are some commands that are supported for the image stitching text detection")
                    .padding()
                
                if didTapNext == 0 {
                    CommandCell(image: "play",headline: "\"Start\"",subtitle: "This command starts capturing images for image stitching.", prevValue: prevValue, didTapNext: didTapNext)
                    
                } else if didTapNext == 1 {
                    CommandCell(image: "pause",headline: "\"Stop\"",subtitle: "This command stops capturing images for image stitching.",prevValue: prevValue, didTapNext: didTapNext)
                } else if didTapNext == 2 {
                    CommandCell(image: "speaker.wave.2.fill",headline: "\"Read to me\"",subtitle: "This reads the text detected by you. This command can be used only after you STOP live detection. This command reads text from the starting.", prevValue: prevValue, didTapNext: didTapNext)
                } else if didTapNext == 3 {
                    CommandCell(image: "chevron.left.circle.fill",headline: "\"Quit Image Stitching\"",subtitle: "This command quits image stitching screen and takes you to the home screen.", prevValue: prevValue, didTapNext: didTapNext)
                    
                } else if didTapNext == 4 {
                    CommandCell(image: "chevron.backward.circle.fill",headline: "Done",subtitle: "This command takes you from the current screen with stitched image to the screen to stitch images again.", prevValue: prevValue, didTapNext: didTapNext)
                    
                }  else if didTapNext == 5 {
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

struct ImageStitcherHelpView_Previews: PreviewProvider {
    static var previews: some View {
        ImageStitcherHelpView()
    }
}

