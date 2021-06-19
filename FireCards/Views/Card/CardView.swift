import SwiftUI

struct CardView: View {
  var cardViewModel: CardViewModel
  @State var showContent: Bool = false
  @State var viewState = CGSize.zero
  @State var showAlert = false
  
  var body: some View {
    ZStack(alignment: .center) {
      backView.opacity(showContent ? 1 : 0)
      frontView.opacity(showContent ? 0 : 1)
    }
    .frame(width: 250, height: 400)
    .background(Color.rwGreen)
    .cornerRadius(20)
    .shadow(color: .rwLight.opacity(0.1), radius: 10, x: 10, y: 10)
    .rotation3DEffect(.degrees(showContent ? 180.0 : 0.0), axis: (x: 0, y: -1, z: 0))
    .offset(x: viewState.width, y: viewState.height)
    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0))
    .onTapGesture {
      withAnimation {
        showContent.toggle()
      }
    }
    .gesture(
      DragGesture()
        .onChanged { value in
          viewState = value.translation
        }
        .onEnded { value in
          if value.location.y < value.startLocation.y - 40.0 {
            self.showAlert.toggle()
          }
          viewState = .zero
        }
    )
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Remove Card"),
        message: Text("Are you sure you want to remove this card?"),
        primaryButton: .destructive(Text("Remove")) {
        },
        secondaryButton: .cancel()
      )
    }
  }
  
  var frontView: some View {
    VStack(alignment: .center) {
      Text(cardViewModel.card.question)
        .foregroundColor(.rwLight)
        .font(.title2)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
        .padding(20.0)
    }
  }
  
  var backView: some View {
    VStack(alignment: .center) {
      Text(cardViewModel.card.answer)
        .foregroundColor(.rwLight)
        .font(.title)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
        .animation(.easeInOut)
    }
    .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
  }
}

struct CardView_Previews: PreviewProvider {
  static var previews: some View {
    let card = testData[0]
    return CardView(cardViewModel: CardViewModel(card: card))
  }
}
