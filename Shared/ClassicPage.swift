//
//  ClassicPage.swift
//  WordleSolver
//
//  Created by Gregory Li on 3/25/22.
//

import SwiftUI
import Combine


struct ClassicPage: View { // check if the word is valid, check if it's correct or 6th guess (boolean) if finished show answer and have a next button create answers list (bottom of words list), make the typing continuos
    @StateObject var bot=Bot()
    @State var arr:[[String]] = Array(repeating: Array(repeating: "", count: 5), count: 6)
    @State var readTemp:[Bool] = Array(repeating: false, count: 7)
    @State var hints:[[Int]] = Array(repeating: Array(repeating: -1, count: 5), count: 6)
    @State var read:[Bool] = Array(repeating: false, count: 6)
    @State var submitted:[Bool] = Array(repeating: false, count: 6)
    @State var wordList:[String]=[]
    @State var answer=""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var numberOfCells: Int = 5
    @State private var currentlySelectedCell = Array(repeating: 0, count: 6)
    @State private var allEmpty:[[Int]] = Array(repeating: [], count:6)
    @State private var correct = 6
    @State private var next = false
    
    var body: some View { // all grey bug (timing issue) // Figure out how to get text, do more research on texts and getting used to getting text methods for text     fields
        DispatchQueue.main.async {
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
                    print(answer+" "+bot.eval(w: arr[i].joined().lowercased(), word: answer))
                    for (j, val) in bot.eval(w: arr[i].joined().lowercased(), word: answer).enumerated() {
                        hints[i][j]=hintMap[val] ?? 0;
                    }
                    print(hints[i])
                    read[i]=true
                    readTemp[i+1]=true
                }
                if hints[i].allSatisfy({$0 == 2}) || submitted[5] {
                    correct=i
                    next=true
                }
            }
        }
        
        return NavigationView {
            ScrollView {
                VStack {
                    ForEach(arr.indices, id: \.self) { i in
                        if readTemp[i] && i<=correct {
                            HStack {
                                Spacer()
                                ForEach(arr[i].indices, id: \.self) { j in
                                    ZStack {
                                        if (!submitted[i]){
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
                                                // .font(.system(size:35))
                                                // .submitLabel(.done)
                                        }
                                        else {
                                            let map = [-1:"gray", 0:"gray", 1:"yellow", 2:"green"]
                                            Image(systemName: "square")
                                            .resizable()
                                            .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.height/15)
                                            .background(Color(col: map[hints[i][j]]!))
                                            .cornerRadius(10)
                                            .overlay(Text(arr[i][j].uppercased()))
                                                .font(.system(size:35))
                                                .textCase(.uppercase)
                                        }
                                    } // ZStack
                                    Spacer()
                                } // ForEach j
                            } // HStack
                        } // end of if prev hints contains -1
                        if !submitted[i] && !arr[i].contains("") && wordList.contains(arr[i].joined().lowercased()) {
                            Button(action: {
                                submitted[i]=true
                            }, label: {
                                Text("SUBMIT").fontWeight(.bold).font(.system(size:24)).foregroundColor(Color.black).padding()
                                    .frame(width: 200.0)
                                    .background(Color.purple)
                                    .overlay(RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.purple, lineWidth: 2))
                            }).cornerRadius(25)
                        }
                    } // ForEach i
                    if submitted[5] && !hints[5].allSatisfy({$0 == 2}) {
                        Text("The answer was "+answer)
                    }
                    if next {
                        Button(action: {
                            answer = wordList[Int.random(in: 0..<bot.getAnswerList().count)]
                            arr = Array(repeating: Array(repeating: "", count: 5), count: 6)
                            readTemp = Array(repeating: false, count: 7)
                            hints = Array(repeating: Array(repeating: -1, count: 5), count: 6)
                            read = Array(repeating: false, count: 6)
                            submitted = Array(repeating: false, count: 6)
                            correct=6
                            currentlySelectedCell = Array(repeating: 0, count: 6)
                            allEmpty = Array(repeating: [], count:6)
                            next=false
                        }, label: {
                            Text("NEXT").fontWeight(.bold).font(.system(size:24)).foregroundColor(Color.black).padding()
                                .frame(width: 200.0)
                                .background(Color.purple)
                                .overlay(RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.purple, lineWidth: 2))
                        }).cornerRadius(25)
                    }
                } // end of VStack
            } // end of scroll view
            .navigationBarItems(leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image("logo").resizable().aspectRatio(contentMode: .fit)
            })
        } // end of nav view
        .onAppear() {
            wordList=bot.getWordList()
            answer=wordList[Int.random(in: 0..<bot.getAnswerList().count)]
        }
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
}

//struct CharacterInputCell: View { // feeds in currently selected & index
//    @State private var textValue: String = ""
//    @Binding var currentlySelectedCell: Int
//
//    var index: Int
//    var arr: [String] 
//    var nextEmpty: Int {
//        for (ind, letter) in arr.enumerated().dropFirst(currentlySelectedCell+1) {
//            if letter.isEmpty {
//                return ind
//            }
//        }
//        return -1
//    }
//
//    var responder: Bool {
//        return index == currentlySelectedCell
//    }
//
//    var body: some View {
//        return CustomTextField(text: $textValue, currentlySelectedCell: $currentlySelectedCell, isFirstResponder: responder, index: index, nextEmpty: nextEmpty)
//    }
//}

struct CustomTextField: UIViewRepresentable { // (update curr=index) (detect delete key in empty text field)

    
    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        @Binding var currentlySelectedCell: Int
        var index: Int
        var nextEmpty: Int = -1
        var allEmpty: [Int]

        var didBecomeFirstResponder = false

        init(text: Binding<String>, currentlySelectedCell: Binding<Int>, index: Int, allEmpty: [Int]) {
            _text = text
            _currentlySelectedCell = currentlySelectedCell
            self.index = index
            self.allEmpty = allEmpty
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }
        
        func updateEmpty(temp: [Int]) {
            allEmpty=temp
        }
        
        func getNextEmpty(index: Int, allEmpty: [Int]) -> Int {
            for x in allEmpty {
                if x>index {
                    return x
                }
            }
            return -1
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            
            guard let stringRange = Range(range, in: currentText) else { return false }

            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.count <= 1 {
                self.currentlySelectedCell=index // updates. just need to update next empty now
                // update next empty here
                nextEmpty = getNextEmpty(index: currentlySelectedCell, allEmpty: allEmpty)
                text=updatedText
                if currentText.isEmpty {
                    self.currentlySelectedCell = nextEmpty == -1 ? currentlySelectedCell+1 : nextEmpty
                }
                else {
                    self.currentlySelectedCell = index
                }
                print("text: "+text+" index: "+String(index))
            }
            
            return updatedText.count <= 1
        }
    }

    @Binding var text: String
    @Binding var currentlySelectedCell: Int
    var isFirstResponder: Bool
    var index: Int
    var allEmpty: [Int]

    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.regular)
        return textField
    }

    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text, currentlySelectedCell: $currentlySelectedCell, index: index, allEmpty: allEmpty)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        context.coordinator.updateEmpty(temp: allEmpty)
        if isFirstResponder && (!context.coordinator.didBecomeFirstResponder || context.coordinator.text.isEmpty) { //
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
    
    func getNextEmpty(index: Int, allEmpty: [Int]) -> Int {
        for x in allEmpty {
            if x>index {
                return x
            }
        }
        return -1
    }
    
    func updateCurr() -> Int{
        return currentlySelectedCell
    }
}

//struct Keyboard: View {
////    @EnvironmentObject var dm: WordleDataModel
//    var topRowArray = "QWERTYUIOP".map{ String($0) }
//    var secondRowArray = "ASDFGHJKL".map{ String($0) }
//    var thirdRowArray = "ZXCVBNM".map{ String($0) }
//    var body: some View {
//        VStack {
//            HStack(spacing: 2) {
//                ForEach(topRowArray, id: \.self) { letter in
//                    LetterButtonView(letter: letter)
//                }
//            }
//            HStack(spacing: 2) {
//                ForEach(secondRowArray, id: \.self) { letter in
//                    LetterButtonView(letter: letter)
//                }
//            }
//            HStack(spacing: 2) {
//                Button {
////                    dm.enterWord()
//                } label: {
//                    Text("Enter")
//                }
//                .font(.system(size: 20))
////                .frame(width: 60, height: 50)
//                .frame(width: UIScreen.main.bounds.width/7,
//                                       height: UIScreen.main.bounds.height/20)
//                .foregroundColor(.primary)
//                ForEach(thirdRowArray, id: \.self) { letter in
//                    LetterButtonView(letter: letter)
//                }
//                Button {
////                    dm.removeLetterFromCurrentWord()
//                } label: {
//                    Image(systemName: "delete.backward.fill")
//                        .font(.system(size: 20, weight: .heavy))
////                        .frame(width: 40, height: 50)
//                        .frame(width: UIScreen.main.bounds.width/10,
//                                               height: UIScreen.main.bounds.height/15)
//                        .foregroundColor(.primary)
//                }
//            }
//        }
//    }
//}

//struct LetterButtonView: View {
////    @EnvironmentObject var dm: WordleDataModel
//    var letter: String
//    var body: some View {
//        Button {
////            dm.addToCurrentWord(letter)
//        } label: {
//            Text(letter)
//                .font(.system(size: 20))
////                .frame(width: 35, height: 50)
//                .frame(width: UIScreen.main.bounds.width/11,
//                                       height: UIScreen.main.bounds.height/20)
//                .background(Color.gray) //dm.keyColors[letter])
//                .foregroundColor(.primary)
//        }
//        .buttonStyle(.plain)
//    }
//}


struct ClassicPage_Previews: PreviewProvider {
    static var previews: some View {
        ClassicPage()
            .preferredColorScheme(.light)
        .previewInterfaceOrientation(.portrait)
    }
}
