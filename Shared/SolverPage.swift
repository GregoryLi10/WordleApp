//
//  SolverPage.swift
//  WordleSolver
//
//  Created by Gregory Li on 3/25/22.
//

import SwiftUI
import Combine

struct SolverPage: View {
    @State var temp=""
    @State var arr:[[String]] = Array(repeating: Array(repeating: "", count: 5), count: 6)
    @State var arrtemp:[[Int]] = Array(repeating: Array(repeating: -1, count: 5), count: 6)
    @State var hints:[[Int]] = Array(repeating: Array(repeating: -1, count: 5), count: 6)
    @State var guesses:[String] = []
    @State var possible:[[String]] = []
    @State var botRan=false
    @State var computing=false
    @State var guessClicked=false
    @State var guess:String = ""
    let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .userInitiated)
    @StateObject var bot=Bot()
    @State private var numberOfCells: Int = 5
    @State private var currentlySelectedCell = Array(repeating: 0, count: 6)
    @State private var allEmpty:[[Int]] = Array(repeating: [], count:6)
    @State var readTemp:[Bool] = Array(repeating: false, count: 7)
    @State var submitted:[Bool] = Array(repeating: false, count: 6)
    @State var read:[Bool] = Array(repeating: false, count: 6)
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        DispatchQueue.main.async {
            var ind=0
            arrtemp[0]=[]
            for index in 1...5 {
                arrtemp[index] = hints[index-1]
            }
            readTemp[0]=true
            for (i, _) in arr.enumerated() {
                allEmpty[i] = getAllEmpty(arr: arr[i], currentlySelectedCell: currentlySelectedCell[i])
                for (j, _) in arr[i].enumerated() {
                    if !arr[i][j].isEmpty && hints[i][j] == -1 {
                        hints[i][j]=0
                    }
                }
                if !readTemp[i] {
                    resetRow(i: i)
                }
//                if !hints[i].contains(-1) {
//                    ind=i
//                }
                if submitted[i] && !read[i] && !(arr[i].contains("")) {
                    let hintMap = [Character("-"):0, Character("x"):1, Character("o"):2]
                    read[i]=true
                    readTemp[i+1]=true
                }
                if submitted[i] && arr[i].contains("") {
                    submitted[i]=false
                    for j in i..<submitted.count {
                        submitted[j] = false
                        readTemp[j+1]=false
                    }
                }
            }
            let letters = "abcdefghijklmnopqrstuvwxyz"
            for (i, _) in arr.enumerated() {
                for (j, _) in arr[i].enumerated() {
                    if !letters.contains(arr[i][j].lowercased()) {
                        arr[i][j]=""
                    }
                    if !arr[i][j].isEmpty && hints[i][j] == -1 {
                        hints[i][j]=0
                    }
                }
                if arrtemp[i].contains(-1) {
                    resetRow(i: i)
                }
                if !hints[i].contains(-1) {
                    ind=i
                }
            }
//            if botTest(ind: ind) {
//                if guesses.isEmpty && botRan == false {
//                    botRan=true
//                    dispatchQueue.async{
//                        bot.setArr(arr: arr)
//                        bot.setHints(hints: hints)
//                        guesses=bot.getBestGuesses(n:5, ind: ind)
//                    }
//                    computing=false
//                }
//                if guessClicked {
//                    arr[1]=Array(arrayLiteral: guess)
//                }
//            }
        }
        return NavigationView {
            ScrollView {
                VStack {
                    ForEach(arr.indices, id: \.self) { i in
                        if readTemp[i] {
                            HStack {
                                Spacer()
                                ForEach(arr[i].indices, id: \.self) { j in
                                    ZStack {
                                        if (arr[i][j].isEmpty && !submitted[i]){
                                            Image(systemName: "square")
                                                .resizable()
                                                .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.height/15)
                                                .background(Color.gray)
                                                .cornerRadius(10)
                                            CustomTextField(text: $arr[i][j], currentlySelectedCell: $currentlySelectedCell[i], isFirstResponder: j == currentlySelectedCell[i], index: j, allEmpty: allEmpty[i])
                                                .disableAutocorrection(true)
                                                .multilineTextAlignment(.center)
                                                .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.height/15)
                                                .cornerRadius(10)
                                                .onReceive(Just(arr[i][j])) { _ in
                                                    limitText([i,j],1)
                                                    let letters = "abcdefghijklmnopqrstuvwxyz"
                                                    if !letters.contains(arr[i][j].lowercased()) {
                                                        arr[i][j]="";
                                                        return;
                                                    }
                                                    arr[i][j]=arr[i][j].uppercased()
                                                }
                                        }
                                        else {
                                            let map = [-1:"gray", 0:"gray", 1:"yellow", 2:"green"]
                                            Menu {
                                                Button(action: {hints[i][j]=2}, label: {
                                                    Label("Green", image: "green")})
                                                Button(action: {hints[i][j]=1}, label: {
                                                    Label("Yellow", image: "yellow")})
                                                Button(action: {hints[i][j]=0}, label: {
                                                    Label("Grey", image: "grey")})
                                                Button(action: {
                                                    arr[i][j]=""
                                                    hints[i][j] = -1
                                                }, label: {
                                                    Label("Delete", systemImage: "delete.left")
                                                })
                                            } label: {
                                                Image(systemName: "square")
                                                .resizable()
                                                .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.height/15)
                                                .background(Color(col: map[hints[i][j]]!))
                                                .cornerRadius(10)
                                                .overlay(Text(arr[i][j].uppercased()))
                                                    .font(.system(size:35))
                                                    .textCase(.uppercase)
                                            }
                                        }
                                    } // ZStack
                                    Spacer()
                                } // ForEach j
                            } // HStack
                            if (!guesses.isEmpty) {
                                ForEach (guesses, id: \.self) { guess in
                                    Button(guess, action:{
                                        guessClicked=true
                                        self.guess=guess
                                     })
                                }
                            }
                            if !hints[i].contains(-1) && !submitted[i] && !arr[i].contains("") {
                                      Button(action: {
                                          submitted[i]=true
                                      }, label: {
                                          Text("SUBMIT").fontWeight(.bold).font(.system(size:24)).foregroundColor(Color.black).padding()
                                              .frame(width: 200.0)
                                              .background(Color.purple)
                                              .overlay(RoundedRectangle(cornerRadius: 25)
                                                  .stroke(Color.purple, lineWidth: 2))
                                      }).cornerRadius(25)
  //                                    botRan=false
  //                                    Button("Compute", action:{botRan=false; computing=true})
  //                                        .fontWeight(.bold).font(.system(size:24)).foregroundColor(Color.black).padding()
  //                                        .frame(width: 200.0)
  //                                        .background(Color.purple)
  //                                        .overlay(RoundedRectangle(cornerRadius: 25)
  //                                            .stroke(Color.purple, lineWidth: 2))
  //                                        .cornerRadius(25)
                            }
//
                        } // end of if read
                        
                    } // ForEach i
                } // end of VStack
            } // end of scroll view
            .navigationBarItems(leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image("logo").resizable().aspectRatio(contentMode: .fit)
            })
        } // end of nav view
    } // end of body
    
    func resetRow(i: Int) {
        arr[i] = Array(repeating: "", count: 5)
        hints[i] = Array(repeating: -1, count: 5)
    }
    
    func limitText(_ index: [Int], _ upper: Int) {
        if arr[index[0]][index[1]].count > upper {
            arr[index[0]][index[1]] = String(arr[index[0]][index[1]].prefix(upper))
        }
    }
    
    func getAllEmpty(arr: [String], currentlySelectedCell: Int) -> [Int] {
        var temp:[Int]=[]
        for (ind, letter) in arr.enumerated() {
            if letter.isEmpty {
                temp.append(ind)
            }
        }
        return temp
    }
    
    func botTest(ind: Int) -> Bool {
        if (!(arr[ind].contains("")) && !hints[ind].contains(1) && !hints[ind].contains(2)) {
            for (index, _) in hints[ind].enumerated() {
                hints[ind][index]=0
            }
        }
        if hints[ind].contains(-1) {
            return false;
        }
        return true;
    }
}

struct SolverPage_Previews: PreviewProvider {
    static var previews: some View {
        SolverPage()
            .preferredColorScheme(.light)
        .previewInterfaceOrientation(.portrait)
    }
}

extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}

//                                            Image(systemName: "square")
//                                                .resizable()
//                                                .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.height/15)
//                                                .background(Color.gray)
//                                                .cornerRadius(10)
//                                            TextField("", text: $arr[i][j])
//                                                .disableAutocorrection(true)
//                                                .multilineTextAlignment(.center)
//                                                .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.height/15)
//                                                .cornerRadius(10)
//                                                .onReceive(Just(arr[i][j])) { _ in limitText([i,j],1)
//                                                }
//                                                .font(.system(size:35))
//                                                .textCase(.uppercase)
//                                                .submitLabel(.done)
