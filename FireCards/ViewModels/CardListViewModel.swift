import Combine

class CardListViewModel: ObservableObject {
  
  @Published var cardRepository = CardRepository()
  
  func add(_ card: Card) {
    cardRepository.add(card)
  }
}
