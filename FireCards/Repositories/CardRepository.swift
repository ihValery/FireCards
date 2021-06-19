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
  
  var userId = ""
  private var authenticationService = AuthenticationService()
  private var cancellabels: Set<AnyCancellable> = []
  
  init() {
    authenticationService.$user
      .compactMap { $0?.uid }
      .assign(to: \.userId, on: self)
      .store(in: &cancellabels)
    
    authenticationService.$user
      .receive(on: DispatchQueue.main)
      //Hаблюдает за изменениями user, использует receive(on:options:) для установки потока,
      //в котором будет выполняться код, а затем присоединяет подписчика с помощью sink(receiveValue:).
      //Это гарантирует, что когда вы получите user from AuthenticationService, код в замыкании будет выполняться в основном потоке.
      .sink { [weak self] _ in
        self?.get()
      }
      .store(in: &cancellabels)
  }
  
  func add(_ card: Card) {
    do {
      //Здесь вы делаете копию card и изменяете ее userId до значения репозитория userId.
      //Теперь каждый раз, когда вы создаете новую карточку, она будет содержать фактический идентификатор пользователя, сгенерированный Firebase.
      var newCard = card
      newCard.userId = userId
      _ = try store.collection(path).addDocument(from: newCard)
    } catch {
      fatalError("Unable to add card: \(error.localizedDescription).")
    }
  }
  
  func get() {
    store.collection(path)
      //Позволяет фильтровать карточки по userId.
      .whereField("userId", isEqualTo: userId)
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
  
  func remove(_ card: Card) {
    guard let cardId = card.id else { return }
    
    store.collection(path).document(cardId).delete { error in
      if let error = error {
        print("Unable to remove card: \(error.localizedDescription)")
      }
    }
  }
}
