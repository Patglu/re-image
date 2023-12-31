import SwiftUI
import RealmSwift
import Combine

struct ProcessedImageView: View {
    @ObservedObject var viewModel: ComparingClothesViewModel
    @ObservedObject var clothingViewModel = ClothingItemViewModel()
    @State private var selectedDescription = ""
    @State private var showExplination: Bool = false
    @State private var selectedFeedback = ""
    @State private var showHome = false
    
    
    var feebackOptions = ["Yes", "No", "Can be improved"]
    var firestoreService = FirestoreService()
    
    init(viewModel: ComparingClothesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(showsIndicators: false){
            Image(uiImage: viewModel.finalOutputImage ?? UIImage())
                .resizable()
                .aspectRatio(3/4, contentMode: .fit)
                .frame(height: 300)
            
            //            BeforeAndAfterSlider(beforeImage: viewModel.image ?? UIImage(),
            //                                 afterImage: viewModel.finalOutputImage ?? UIImage())
            VStack(alignment: .leading) {
                Text("Description")
                    .bold()
                    .padding(.top)
                Text("Please select the most accurate description or add your own")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(viewModel.imageDescritptors, id: \.self) { word in
                            Text(word)
                                .padding()
                                .foregroundColor(.white)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(selectedDescription == word ? .blue : .gray)
                                }
                                .onTapGesture {
                                    selectedDescription = word
                                }
                        }
                    }
                }
                
                if !viewModel.colorsFromImage.isEmpty {
                    Text("Colour palette")
                        .bold()
                        .padding(.top)
                    
                    HStack(spacing: 0){
                        ForEach(viewModel.colorsFromImage, id: \.self) { color in
                            Rectangle()
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color(uiColor: color))
                        }
                    }
                    
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Divider()
                    .padding(.vertical)
                
                Text("Feedback")
                    .bold()
                    .padding(.top)
                HStack{
                    Text("Was the description accurate")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                    Picker("Was the description accurate", selection: $selectedFeedback) {
                        ForEach(feebackOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
            }
            .padding()
            
            Spacer()
            
            Text("Done")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(content: {
                    RoundedRectangle(cornerRadius: 15)
                        .opacity(selectedFeedback == "" && selectedDescription == "" ? 0.4 : 1)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                })
             
                .onTapGesture {
                    let hexColors  = viewModel.colorsFromImage.map { $0.hexString() }
                    let newItem = Clothingitem()
                    
                    newItem.itemImage = viewModel.finalOutputImage?.toJSONString() ?? ""
                    newItem.itemFeedback = selectedFeedback
                    newItem.itemDescription = selectedDescription
                    for hexColor in hexColors {
                        newItem.colors.append(hexColor)
                    }
                    
                    //Send to firebase
                    clothingViewModel.addItem(newItem: newItem)
                    
                    //Save to realm
                    let realm = try! Realm()
                    
                    try? realm.write{
                        realm.add(newItem)
                        viewModel.clearFields()
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                    }
                }
                .disabled(selectedFeedback == "" && selectedDescription == "")
                
            Spacer()
                .frame(height: 50)
        }
        .sheet(isPresented: $showHome) {
            HomeView()
        }
        .redacted(reason: viewModel.finalOutputImage == nil ? .placeholder : [])
        
    }
}

struct ProcessedImageView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessedImageView(viewModel: ComparingClothesViewModel())
    }
}
