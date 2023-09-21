import SwiftUI
struct ImagesFromURL: View {
    @ObservedObject var viewModel: ComparingClothesViewModel
    @State private var urlToSearch: String = ""
    
    init(viewModel: ComparingClothesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView{
            VStack {
                HStack {
                    TextField("Please enter a url", text: $urlToSearch)
                    Button {
                        //                    viewModel.predictClothingURL(urlString: urlToSearch)
                        viewModel.imagesFromURL = []
                        viewModel.getImagesFromURL(urlString: urlToSearch)
                    } label: {
                        Text("GO")
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
                if viewModel.isLoading == false {
                    ScrollView(.horizontal){
                        LazyHStack{
                            ForEach(viewModel.imagesFromURL ?? [], id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .onTapGesture {
                                        viewModel.selectedURLImage = image
                                        
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ProgressView()
                }
                if let safeSelection = viewModel.selectedURLImage {
                    VStack{
//                        if viewModel.classLabel.isEmpty{
//                            
//                        } else {
//                            Text(viewModel.classLabel)
//                        }
                        
                        HStack{
                            Image(uiImage: safeSelection)
                                .resizable()
                                .scaledToFit()
                                .opacity(0.6)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding(.horizontal)
                            if let image = viewModel.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .mask{
                                        if let maskImage = viewModel.finalOutputImage {
                                            Image(uiImage: maskImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                        } else {
                                            EmptyView()
                                        }
                                    }
                                
                            }
                        }
                        HStack {
                            Button("Cancel") {
                                viewModel.selectedURLImage = nil
                            }
                            Button("Mask") {
                                viewModel.image = safeSelection
//                                viewModel.predictClothingItem()
                            }
                        }
                    }
                    .padding()
                } else {
                    
                }
            }
            //        .animation(.easeInOut)
        }
    }
}

struct ImagesFromURL_Previews: PreviewProvider {
    static var previews: some View {
        ImagesFromURL(viewModel: ComparingClothesViewModel())
    }
}
