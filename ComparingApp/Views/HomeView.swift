
import SwiftUI
import RealmSwift

struct HomeView: View {
    @ObservedResults(Clothingitem.self) var clothingItems
    @State private var showAddingMenu: Bool = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())]
    
    
    var body: some View {
        ScrollView {
            if clothingItems.isEmpty {
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
                    ForEach(clothingItems) { item in
                        RoundedRectangle(cornerRadius: 15)
                            .frame(height: 200)
                            .foregroundColor(.clear)
                            .overlay(alignment: .center){
                                VStack{
                                    if let image = item.itemImage.toUIImage(){
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                        Text(item.itemDescription)
                                        HStack(spacing: 0) {
                                            ForEach(item.colors, id:\.self) { color in
                                                Rectangle()
                                                    .foregroundColor(Color(uiColor: color.hexToUIColor() ?? UIColor()))
                                                    .frame(height: 10)
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                            .overlay(content: {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(lineWidth: 1)
                                    .foregroundColor(.gray.opacity(0.3))
                            })
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
        .onAppear{
            Clothingitem.defineMigrationBlock()
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
