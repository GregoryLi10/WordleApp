//
//  ContentView.swift
//  Shared
//
//  Created by Gregory Li on 3/21/22.
//
// structs for new pages, returns view
// let is basically const, var is any mutable variable
// there's also something like computable variables
// every view can only have 1 item so you usually use stacks
// embedded stacks (ZStack for z axis, VStack for y axis, HStack for x axis)
// Spacer(), Stack(spacing: 0.0){, padding() all used to space things

import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        NavigationView{
            ZStack {
                VStack (spacing: 20.0){
                    NavigationLink(destination: SolverPage().navigationBarHidden(true)) {
                        Text("SOLVER").fontWeight(.bold).font(.system(size:24)).foregroundColor(Color.black).padding()
                            .frame(width: 200.0)
                            .background(Color.purple)
                            .overlay(RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.purple, lineWidth: 2))
                    }.cornerRadius(25)
                    NavigationLink(destination: ClassicPage().navigationBarHidden(true)) {
                        Text("CLASSIC").fontWeight(.bold).font(.system(size:24)).foregroundColor(Color.black).padding()
                            .frame(width: 200.0)
                            .background(Color.purple)
                            .overlay(RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.purple, lineWidth: 2))
                    }.cornerRadius(25)
                    NavigationLink(destination: SectionedTextField().navigationBarHidden(false)) {
                        Text("test").fontWeight(.bold).font(.system(size:24)).foregroundColor(Color.black).padding()
                            .frame(width: 200.0)
                            .background(Color.purple)
                            .overlay(RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.purple, lineWidth: 2))
                    }.cornerRadius(25)
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action:{}, label: {Image("logo").resizable().aspectRatio(contentMode: .fit)})
                }
            }
        }

//        NavigationView {
//           NavigationLink(destination: DestView(passed: self.$destContent)) {
//               Text("Press on me").padding().background(Color.gray)
//           }.buttonStyle(PlainButtonStyle())
//        }
    }
}

extension Color {
    init?(col: String) {
        switch col {
        case "gray":        self = .gray
        case "green":       self = .green
        case "yellow":      self = .yellow
        default:            return nil
        }
    }
}
                                   
extension AnyTransition {
   static var backslide: AnyTransition {
       AnyTransition.asymmetric(
           insertion: .move(edge: .trailing),
           removal: .move(edge: .leading))}
}

//struct CustomTextField: View {
//    @Binding var str: String
//    let placeholder: Text
//    let systemImageName: String
//    var body: some View {
//        ZStack {
//            if str.isEmpty {
//                placeholder
//                    .foregroundColor(Color(.init(white: 3, alpha: 0.87)))
//                    .padding(.leading, 40)
//            }
//            HStack {
//                Image(systemName: systemImageName)
//                    .resizable()
//                    .scaledToFit()
//                    .frame (width: 20, height: 20)
//                    .foregroundColor(.white)
//                TextField("", text: $str)
//            }
//        }
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
            .previewInterfaceOrientation(.portrait)
        }
    }
}
