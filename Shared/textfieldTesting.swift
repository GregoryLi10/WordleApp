//
//  textfieldTesting.swift
//  WordleSolver
//
//  Created by Gregory Li on 4/1/22.
//

import UIKit
import SwiftUI
import Combine

struct SectionedTextField: View {
    @State private var numberOfCells: Int = 5
    @State private var currentlySelectedCell = 0
    @State private var allEmpty:[Int] = []

    @State private var arr: [String] = Array(repeating: "", count: 5)

    var body: some View {
        DispatchQueue.main.async {
            if currentlySelectedCell >= numberOfCells {
                currentlySelectedCell = numberOfCells-1
            }
            allEmpty = getAllEmpty(arr: arr, currentlySelectedCell: currentlySelectedCell)
        }
        print(arr)
        return HStack { // arrays of rows (arr[i]), next empty (after curr), previous filled (before curr), if valid letter, next empty (or last), if delete, go to previous filled (or first)
            ForEach (arr.indices, id: \.self) { j in
                ZStack {
                    Image(systemName: "square")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.height/15)
                        .background(Color.gray)
                        .cornerRadius(10)
                    CustomTextField(text: $arr[j], currentlySelectedCell: $currentlySelectedCell, isFirstResponder: j == currentlySelectedCell, index: j, allEmpty: allEmpty)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.center)
                        .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.height/15)
                        .cornerRadius(10)
                        .onReceive(Just(arr[j])) { _ in
                            limitText([j],1)
                            let letters = "abcdefghijklmnopqrstuvwxyz"
                            if !letters.contains(arr[j].lowercased()) {
                                arr[j]="";
                                return;
                            }
                            arr[j]=arr[j].uppercased()
                        }
                        .font(.system(size:35))
                        .submitLabel(.done)
//                        .onChange(of: arr[j]) { newValue in
//                            currentlySelectedCell=j
//                        } //doesn't work because it freezes after change (has to be done somewhere in custom text field)
                }
            }
        }
    }

    func limitText(_ index: [Int], _ upper: Int) {
        if arr[index[0]].count > upper {
            arr[index[0]] = String(arr[index[0]].prefix(upper))
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

//struct SectionedTextField: View {
//    @State private var numberOfCells: Int = 5
//    @State private var currentlySelectedCell = 0
//    @State private var nextEmpty = -1
//
//    @State private var arr: [String] = Array(repeating: "", count: 5)
//
//    var body: some View {
//        return HStack {
//            ForEach (0..<numberOfCells) { j in
//                CharacterInputCell(currentlySelectedCell: self.$currentlySelectedCell, index: j, arr: self.arr);
//            }
//        }
//    }
//}

//struct SectionedTextField: View {
//    @State private var numberOfCells: Int = 8
//    @State private var currentlySelectedCell = 0
//
//    var body: some View {
//        HStack {
//            ForEach(0 ..< self.numberOfCells) { index in
//                CharacterInputCell(currentlySelectedCell: self.$currentlySelectedCell, index: index)
//            }
//        }
//    }
//}
//
//struct CharacterInputCell: View {
//    @State private var textValue: String = ""
//    @Binding var currentlySelectedCell: Int
//
//    var index: Int
//
//    var responder: Bool {
//        return index == currentlySelectedCell
//    }
//
//    var body: some View {
//        CustomTextField(text: $textValue, currentlySelectedCell: $currentlySelectedCell, isFirstResponder: responder)
//            .frame(height: 20)
//            .frame(maxWidth: .infinity, alignment: .center)
//            .padding([.trailing, .leading], 10)
//            .padding([.vertical], 15)
//            .lineLimit(1)
//            .multilineTextAlignment(.center)
//            .overlay(
//                RoundedRectangle(cornerRadius: 6)
//                    .stroke(Color.red.opacity(0.5), lineWidth: 2)
//            )
//    }
//}
//
//struct CustomTextField: UIViewRepresentable {
//
//    class Coordinator: NSObject, UITextFieldDelegate {
//
//        @Binding var text: String
//        @Binding var currentlySelectedCell: Int
//
//        var didBecomeFirstResponder = false
//
//        init(text: Binding<String>, currentlySelectedCell: Binding<Int>) {
//            _text = text
//            _currentlySelectedCell = currentlySelectedCell
//        }
//
//        func textFieldDidChangeSelection(_ textField: UITextField) {
//            DispatchQueue.main.async {
//                self.text = textField.text ?? ""
//            }
//        }
//
//        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//            let currentText = textField.text ?? ""
//
//            guard let stringRange = Range(range, in: currentText) else { return false }
//
//            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
//
//            if updatedText.count <= 1 {
//                self.currentlySelectedCell += 1
//            }
//
//            return updatedText.count <= 1
//        }
//    }
//
//    @Binding var text: String
//    @Binding var currentlySelectedCell: Int
//    var isFirstResponder: Bool = false
//
//    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
//        let textField = UITextField(frame: .zero)
//        textField.delegate = context.coordinator
//        textField.textAlignment = .center
//        return textField
//    }
//
//    func makeCoordinator() -> CustomTextField.Coordinator {
//        return Coordinator(text: $text, currentlySelectedCell: $currentlySelectedCell)
//    }
//
//    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
//        uiView.text = text
//        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
//            uiView.becomeFirstResponder()
//            context.coordinator.didBecomeFirstResponder = true
//        }
//    }
//}
