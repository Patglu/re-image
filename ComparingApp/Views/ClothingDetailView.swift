import SwiftUI
import RealmSwift

struct ClothingDetailView: View {
    let clothingItem: Clothingitem
    @ObservedObject var viewModel: RealmViewModel
    @State private var editedDescription: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(clothingItem: Clothingitem, viewModel: RealmViewModel) {
        self.clothingItem = clothingItem
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(showsIndicators: false){
            if let image = clothingItem.itemImage.toUIImage() {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(height: 250)
            }
            
            VStack(alignment: .leading) {
                Text("Description")
                    .bold()
                    .padding(.top)
                Text("Please select the most accurate description or add your own")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                TextField(clothingItem.itemDescription, text: $editedDescription)
                
                
                Text("Colour palette")
                    .bold()
                    .padding(.top)
                
                HStack(spacing: 0){
                    ForEach(clothingItem.colors, id: \.self) { color in
                        Rectangle()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color(uiColor: color.hexToUIColor() ?? UIColor()))
                    }
                }
                
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                
                Divider()
                    .padding(.vertical)
                
                
            }
            .padding()
            
            Spacer()
            
            Text("Delete")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(content: {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                })
                .onTapGesture {
                    viewModel.remove(id: clothingItem.id.stringValue)
                    presentationMode.wrappedValue.dismiss()
                }
            
            Spacer()
                .frame(height: 50)
        }
        .toolbar {
            Button {
                if editedDescription == "" {
                     presentationMode.wrappedValue.dismiss()
                } else {
                    viewModel.updateTitle(clothingItem, newTitle: editedDescription) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
               
            } label: {
                Text("Done")
            }
            
        }
    }
}

struct ClothingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ClothingDetailView(clothingItem: Clothingitem(), viewModel: RealmViewModel())
    }
}
