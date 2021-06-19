import Combine

class CardListViewModel: ObservableObject {
  
  @Published var cardRepository = CardRepository()
  @Published var cardViewModels: [CardViewModel] = []
  private var cancellabeles: Set<AnyCancellable> = []
  
  init() {
    cardRepository.$cards.map { cards in
      cards.map(CardViewModel.init)
    }
    .assign(to: \.cardViewModels, on: self)
    .store(in: &cancellabeles)
  }
  
  func add(_ card: Card) {
    cardRepository.add(card)
  }
}
