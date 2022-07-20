

// Possible is now 2d array with [i][j] i being the guess no.
// now it runs twice and i cant fix it

import SwiftUI

class Bot: ObservableObject {
    private var arr:[[String]]
    private var hints:[[Int]]
    private var wordList:[String] {
        var words:[String] = []
        do {
            if let path = Bundle.main.path(forResource: "words", ofType: "txt") {
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                words = data.components(separatedBy: "\n")
            }
            else {
//                print ("no path")
            }
        } catch let err as NSError {
            print(err)
        }
        words.removeLast()
        return words;
    }
    private var possible:[[String]]=[]
    
    init(){
        arr=[]
        hints=[]
        print("bot")
    }
    
    init(arr:[[String]], hints:[[Int]]) {
        self.arr=arr
        self.hints=hints
    }
    
    func setArr(arr:[[String]]) {
        self.arr=arr
    }
    
    func setHints(hints:[[Int]]) {
        self.hints=hints
    }
        
    func getWordList() -> [String] {
        return wordList;
    }
    
    func getAnswerList() -> [String] {
        return Array(wordList.prefix(2315))
    }
    
    func getBestGuesses(n:Int, ind:Int) -> [String] {
        let start = CFAbsoluteTimeGetCurrent()
        let w=arr[ind].joined().lowercased()
        var h=""
        let hintMap = [0:"-", 1:"x", 2:"o"]
        for (_, hint) in hints[ind].enumerated() {
            h.append(hintMap[hint]!)
        }
        if (ind==0) {
            possible.append(reduce(ev: h, w: w, possible: wordList))
        }
        else {
            possible.append(reduce(ev: h, w: w, possible: possible[ind-1]))
        }
        var matrix:[[Int]] = Array(repeating: Array(repeating: 0, count: possible[ind].count), count: wordList.count), min:[[Int]] = Array(repeating: Array(repeating: possible[ind].count/2, count: n), count: 2)
        var max:[Int]=Array(repeating: 0, count: wordList.count)
        if (possible[ind].count==1 || possible[ind].count==2) {
            return possible[ind]
        }
        else if (possible[ind].count==0) {
            return ["no possible answers"]
        }
        print("check 1")
        print(possible[0].count)
        print(possible.count)
        outerloop:
        for (k, listWord) in wordList.enumerated() { 
            if (k%100==99) {print(k/100)}
            for (j, posWord) in possible[ind].enumerated() {
                if (listWord == posWord) {
                    matrix[k][j] = 1;
                }
                else {
//                    eval(w:listWord, word:posWord)
                    matrix[k][j] = reduce(ev:eval(w:listWord, word:posWord), w:listWord, possible:possible[ind]).count
                } // (eval)fixed infinite loop (reduce)causes memory issues
                if (matrix[k][j]>max[k]) {
                    max[k]=matrix[k][j];
                    if (max[k]>min[0][min[0].count-1]){
                        continue outerloop;
                    }
                }
            }
            for (i, minVal) in min[0].enumerated() {
                if (max[k] >= minVal) {
                    continue;
                }
                min[0][i]=max[k];
                min[1][i]=k;
                break;
            }
        }
        print(possible[ind])
        print(min)
        var guesses:[String]=[]
        for z in min[1] {
            guesses.append(wordList[z]);
        }
        print("check 2")
        print("Time: "+String(CFAbsoluteTimeGetCurrent() - start))
        return guesses
    }
    
    func reduce(ev:String, w:String, possible:[String]) -> [String] {
        var temp:[String]=[]
        var dup = ""
        if (Set(w).count != w.count) {
            var duplicateFinder=Array(w)
            duplicateFinder.sort()
            for (i, dupFinder) in duplicateFinder.enumerated().dropFirst() {
                if (dupFinder == duplicateFinder[i-1] && !dup.contains(dupFinder)) {
                    dup += String(dupFinder)
                }
            }
        }
        for pos in possible {
            if (reducer(e: ev, w: w, possible: pos, duplicate: dup)) {
                temp.append(pos)
            }
        } //this works?
        return temp
    }
    
        
    func reducer(e:String, w:String, possible:String, duplicate:String) -> Bool { //reducer with !dup.isEmpty has inifinite loop
        var dup:[Character]=[]
        var a=true;
        for (i, wVal) in w.enumerated() {
            if duplicate.contains(wVal) {
                dup.append(contentsOf: [Character(UnicodeScalar(i)!)])
                dup.append(wVal)
                continue;
            }
            else if e[i] == "o" {
                a = possible[i] == wVal;
            }
            else if e[i] == "x" {
                a = possible.contains(wVal) && wVal != possible[i];
            }
            else {
                a = !possible.contains(wVal);
            }
            if (!a) {
                return false
            }
        }
        
        dup.sort()  //w is guess, possible is possible answer
        for dupliVal in duplicate {
            var s=""
            var j=w.firstIndex(of: dupliVal)
            while j != nil {
                s += e[w.distance(from: w.startIndex, to: j!)]; //index out of range
                j=w.suffix(w.count-(w.distance(from: w.startIndex, to: j!)+1)).firstIndex(of: dupliVal)
            }
            
            if s.allSatisfy({$0 == "-"}) && possible.contains(dupliVal) {
                return false;
            }
            else if s.contains("-") && !possible.contains(dupliVal) {
                continue;
            }
            if possible.filter({$0 == dupliVal}).count >= dup.filter({$0 == dupliVal}).count {
                if (s.contains("-")) {
                    return false;
                }
                for (wVal, (eVal, possibleVal)) in zip(w, zip(e, possible)) where duplicate.contains(wVal) {
                    if (eVal == "o") {
                        a = possibleVal == wVal;
                    }
                    else if (eVal == "x") {
                        a = possible.contains(wVal) && wVal != possibleVal;
                    }
                    if (!a) {
                        return false;
                    }
                }
            } // if guess has more letters than possible answer (this works i believe)
            else {
                var c:Int = s.filter({$0 == "o"}).count
                if (c > possible.filter({$0 == dupliVal}).count) {
                    return false;
                }
                if (c == possible.filter({$0 == dupliVal}).count) {
                    if (s.contains("x")) {
                        return false;
                    }
                }
                else if (c == 0 && s[0] == "-") {
                    return false;
                }
                else {
                    for sepVal in s {
                        if (sepVal == "x") {
                            c+=1;
                        }
                    }
                    if c != possible.filter({$0 == dupliVal}).count {
                        return false;
                    }
                } // everything above this works jk (ev is used to test if the word is a possibility u idiot)
                for (wVal, (eVal, possibleVal)) in zip(w, zip(e, possible)) where duplicate.contains(wVal) { // might want to use zip if it still causes memory/runtime issues
                    if (!duplicate.contains(wVal)) {
                        continue;
                    }
                    if (eVal == "o") {
                        a = possibleVal == wVal;
                    }
                    else if (eVal == "x") {
                        a = possible.contains(wVal) && wVal != possibleVal;
                    }
                    else {
                        a = wVal != possibleVal;
                    }
                    if (!a) {
                        return false;
                    }
                }
            } // fix this else
        }
        return true;
    }
    
    func eval(w:String, word:String) -> String { //does not work properly
        if Set(w).count == w.count {
            var s=""
            for (wVal, wordVal) in zip(w, word) {
                s.append(evaluate(a:wVal, letter: wordVal, word: word))
            }
            return s;
        } //if no duplicates, else:
        let dup=String(Set(w.filter({ (i: Character) in w.filter({ $0 == i }).count > 1})))
        var hint:[Character] = Array(repeating: ("-"), count: 5)
        for (i, (wVal, wordVal)) in zip(w, word).enumerated() where !dup.contains(wVal) {
            hint[i]=evaluate(a:wVal, letter:wordVal, word:word)
        }
        for dupVal in dup {
            if !word.contains(dupVal) {
                continue
            }
            else if word.filter({$0 == dupVal}).count >= w.filter({$0 == dupVal}).count {
                for (j, (wVal, wordVal)) in zip(w, word).enumerated() where wVal == dupVal {
                    hint[j]=evaluate(a:wVal, letter:wordVal, word:word);
                }
            }
            else {
                var c:Int = word.filter({$0 == dupVal}).count
                for (index, (wVal, wordVal)) in zip(w, word).enumerated() where wVal == dupVal && wVal == wordVal{
                    hint[index] = "o";
                    c -= 1
                }
                for (k, (wVal, dupliVal)) in zip(w, hint).enumerated() where wVal == dupVal && dupliVal != "o" && dupliVal != "x"{
                    if (c<=0) {break}
                    hint[k] = "x";
                    c -= 1
                }
//                for (j, dupFinder) in hint.enumerated() where dupFinder != "-" && dupFinder != "o" && dupFinder != "x" {
//                    hint[j]="-"
//                }
            }
        }
        return String(hint)
    }
    
    func valid(w:String) -> Bool {
        return w.count==5 && wordList.contains(w.lowercased());
    }
        
    func evaluate(a:Character, letter:Character, word:String) -> Character {
        if (a == letter) {
            return "o"
        }
        if (word.contains(a)) {
            return "x"
        }
        return "-"
    }
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
