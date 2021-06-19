//FirebaseFirestoreSwift добавляет несколько интересных функций, которые помогут вам интегрировать Firestore с вашими моделями.
//Он позволяет конвертировать Cards в документы и документы в Cards.

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class CardRepository: ObservableObject {
  //Oбъявите path и присвойте значение cards. Это название коллекции в Firestore.
  private let path: String = "cards"
  private let store = Firestore.firestore()
  
  func add(_ card: Card) {
    do {
      _ = try store.collection(path).addDocument(from: card)
    } catch {
      fatalError("Unable to add card: \(error.localizedDescription).")
    }
  }
}
