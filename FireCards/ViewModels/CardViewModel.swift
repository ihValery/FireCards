import Combine

class CardViewModel: ObservableObject, Identifiable {
  
  private let cardRepository = CardRepository()
  @Published var card: Card
  //cancellables используется для хранения ваших подписок, чтобы вы могли отменить их позже.
  private var cancellables: Set<AnyCancellable> = []
  var id = ""
  
  init(card: Card) {
    self.card = card
    //Настройте привязку card между карточкой id и моделью представления id.
    //Затем сохраните объект cancellables чтобы его можно было отменить позже.
    $card
      .compactMap { $0.id }
      //Результат этого преобразования затем используется  подписчиком  assign, который — как следует из названия — назначает полученное значение
      .assign(to: \.id, on: self)
      .store(in: &cancellables)
  }
  
  func update(card: Card) {
    cardRepository.update(card)
  }
}
