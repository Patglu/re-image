
import SwiftUI
import RealmSwift

struct HomeView: View {
    @StateObject var viewModel = RealmViewModel()
    @State private var showAddingMenu: Bool = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())]
    
    
    var body: some View {
        ScrollView {
            if viewModel.clothes.isEmpty {
                HStack{
                    RoundedRectangle(cornerRadius: 15)
                        .opacity(0.15)
                        .overlay {
                            VStack(spacing: 20){
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                    .bold()
                                
                                Text("Add new item to your library")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width / 2.2 , height: 200)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            showAddingMenu.toggle()
                        }
                    Spacer()
                }
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.clothes) { item in
                        NavigationLink {
                            ClothingDetailView(clothingItem: item, viewModel: viewModel)
                        } label: {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(height: 200)
                                .foregroundColor(.clear)
                                .overlay(alignment: .center){
                                    ClothingItemGridCell(clothingItem: item)
                                }
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(lineWidth: 1)
                                        .foregroundColor(.gray.opacity(0.3))
                                })
                        }
                        .tint(.black)
                    }
                    
                }
            }
        }
        .padding()
        .navigationTitle("Library")
        .toolbar {
            Button {
                showAddingMenu.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.black)
            }
            
        }
        .sheet(isPresented: $showAddingMenu) {
            NavigationView {
                ChooseClothesView()
            }
        }

    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            HomeView()
        }
    }
}
