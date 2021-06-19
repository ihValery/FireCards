import Foundation

struct Card: Identifiable, Codable {
  var id: String = UUID().uuidString
  var question: String
  var answer: String
  var successful: Bool = true
  var userId: String?
}

#if DEBUG
let testData = (1...10).map { i in
  Card(question: "Question #\(i)", answer: "Answer #\(i)")
}
#endif
