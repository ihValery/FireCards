//FirebaseFirestoreSwift добавляет несколько интересных функций, которые помогут вам интегрировать Firestore с вашими моделями.
//Он позволяет конвертировать Cards в документы и документы в Cards.

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class CardRepository: ObservableObject {
  @Published var cards: [Card] = []
  //Oбъявите path и присвойте значение cards. Это название коллекции в Firestore.
  private let path: String = "cards"
  private let store = Firestore.firestore()
  
  init() {
    get()
  }
  
  func add(_ card: Card) {
    do {
      _ = try store.collection(path).addDocument(from: card)
    } catch {
      fatalError("Unable to add card: \(error.localizedDescription).")
    }
  }
  
  func get() {
    store.collection(path)
      //добавьте слушателя для получения изменений в коллекции.
      .addSnapshotListener { querySnapshot, error in
        if let error = error {
          print("Error getting cards: \(error.localizedDescription)")
          return
        }
        //Используйте compactMap (_ :) on querySnapshot.documents для перебора всех элементов.
        self.cards = querySnapshot?.documents.compactMap { document in
          //Сопоставьте каждый документ с Card использованием data(as:decoder:). Вы можете сделать это благодаря FirebaseFirestoreSwift, который вы импортировали вверху, и потому что Card соответствует Codable
          try? document.data(as: Card.self)
          //Если querySnapshot есть nil, вы будете установить вместо пустого массива.
        } ?? []
      }
  }
  
  func update(_ card: Card) {
    guard let cardId = card.id  else { return }
    do {
      //Используя path и cardId, он получает ссылку на документ в коллекции карточек,
      //а затем обновляет поля, передавая card в setData(from).
      try store.collection(path).document(cardId).setData(from: card)
    } catch {
      fatalError("Unable to update card: \(error.localizedDescription).")
    }
  }
}
