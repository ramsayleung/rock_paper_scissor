//
//  ContentView.swift
//  RockPaperScissor
//
//  Created by ramsayleung on 2023-12-27.
//

import SwiftUI

struct FlagImage: View{
    let name: String
    var body: some View{
        ZStack{
            let base = Circle().fill(.thinMaterial)
                .frame(width: 100, height: 100)
            Group{
                base
                Text(name)
                    .font(.system(size: 60))
            }
        }.animation(.linear, value: name)
    }
}

enum Move: String, CaseIterable {
    case Paper = "✋"
    case Rock = "✊"
    case Scissor = "✌️"
    
    func winMove() -> Self{
        switch self{
        case .Paper:
            return .Scissor
        case .Rock:
            return .Paper
        case .Scissor:
            return .Rock
        }
    }
    
    func loseMove() -> Self{
        switch self{
        case .Paper:
            return .Rock
        case .Rock:
            return .Scissor
        case .Scissor:
            return .Paper
        }
    }
    
    func name() -> String{
        switch self{
        case .Paper:
            return "Paper"
        case .Rock:
            return "Rock"
        case .Scissor:
            return "Scissor"
        }
        
    }
}

enum Choice: String, CaseIterable{
    case Win = "😎"
    case Lose = "😵‍💫"
    
    func name() -> String {
        switch self {
        case .Win:
            return "Win"
        case .Lose:
            return "Lose"
        }
    }
}

struct CountdownTimerView: View {
    @Binding var timeRemaining: Int
    let total: Int
    let width: Double
    let height: Double
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 20))
                    .frame(width: width, height: height)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(timeRemaining) / Double(total))
                    .stroke(timeRemaining > (total/2) ? Color.indigo: Color.red, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0))
                
                Image(systemName: "timer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width/2, height: height/2)
                    .foregroundColor(timeRemaining > (total/2) ? Color.indigo: Color.red)
            }
        }
    }
}

struct ContentView: View {
    @State private var currentMove = Int.random(in: 0..<3)
    @State private var currentChoice = Bool.random()
    @State private var selectedMove: Move?
    @State private var answer = ""
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var timer: Timer?
    @State private var questionCount = 0
    @State private var correctAnswer = false
    @State private var showingFinalJudge = false
    
    var body: some View {
        VStack{
            Text("Rock Paper Scissor")
                .font(.largeTitle)
            Spacer()
            
            HStack{
                VStack{
                    Text("Current Move")
                        .font(.title)
                    FlagImage(name: Move.allCases[currentMove].rawValue)
                        .foregroundColor(.green)
                    Text(Move.allCases[currentMove].name())
                }
                
                VStack{
                    Text("Current Choice")
                        .font(.title)
                    FlagImage(name: currentChoice ? Choice.Win.rawValue : Choice.Lose.rawValue)
                    Text(currentChoice ? Choice.Win.name() : Choice.Lose.name())
                }
            }
            Spacer()
            CountdownTimerView(timeRemaining: $timeRemaining, total: 10, width: 100, height: 100)
                .onAppear(perform: startTimer)
                .onDisappear(perform: stopTimer)
            Spacer()
            VStack{
                Text("Select your Move")
                    .font(.largeTitle)
                HStack(spacing: 15) {
                    ForEach(Move.allCases, id: \.self){ move in
                        Button {
                            selectedMove = move
                            judgeAnswer(selectedMove: move)
                        } label: {
                            FlagImage(name: move.rawValue)
                                .background(selectedMove == move ? (correctAnswer ? Color.green : Color.red) : Color.clear)
                            
                        }.disabled(selectedMove != nil)
                    }
                }
                
                Text(answer)
                    .foregroundColor(correctAnswer ? .green : .red)
                    .font(.headline)
            }
            .alert("Your final judge", isPresented: $showingFinalJudge){
                Button("Restart") {
                    restart()
                }
            } message: {
                Text("Your final score is: \(score)")
            }
            Spacer()
            
            VStack(spacing: 10){
                Text("Answered question count: \(questionCount)")
                    .font(.headline)
                
                HStack{
                    Text("Your score is: ")
                        .font(.largeTitle)
                    Text("\(score)")
                        .foregroundColor(score > 0 ? .green : score < 0 ? .red: .primary)
                        .font(.largeTitle)
                }
                
            }
            
        }
    }
    
    func judgeAnswer(selectedMove: Move) {
        var currentScore = 0
        if (currentChoice && selectedMove == Move.allCases[currentMove].winMove()) || (!currentChoice && selectedMove == Move.allCases[currentMove].loseMove()){
            currentScore = 1
            answer = "Great move!"
            correctAnswer = true
        }else{
            answer = "Bad move :("
            currentScore = -1
            correctAnswer = false
        }
        
        // Start a timer to reset the question after 3 seconds
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            startNewQuestionOrNewGame(currentScore: currentScore)
        }
    }
    
    func startNewQuestionOrNewGame(currentScore: Int) {
        if questionCount >= 10 {
            showingFinalJudge = true
        }else{
            score += currentScore
            newQuestion()
        }
    }
    
    func restart(){
        newQuestion()
        questionCount = 0
        score = 0
    }
    
    func newQuestion(){
        print("newQuestion")
        currentMove = generateRandomNumber(excluding: currentMove, inRange: 0...2)
        currentChoice.toggle()
        answer = ""
        questionCount += 1
        timeRemaining = 10
        timer?.fire()
        selectedMove = nil
    }
    
    func wrongAnswer() {
        startNewQuestionOrNewGame(currentScore: -1)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // timer?.invalidate() // Stop the timer when time is up
                // time up means wrong answer
                wrongAnswer();
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func generateRandomNumber(excluding currentNumber: Int, inRange range: ClosedRange<Int>) -> Int {
        var randomNumber = currentNumber
        while randomNumber == currentNumber {
            randomNumber = Int.random(in: range)
        }
        return randomNumber
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
