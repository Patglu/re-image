import SwiftUI
import RealmSwift

struct ChooseClothesView: View {
    @EnvironmentObject var viewModel: ComparingClothesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var chosenButtonClicked: Bool = false
    @State private var shouldShowSheet: Bool = false
    @State private var showSheet: Bool = false
    @State var textTotype = ""
    
    var body: some View {
        
        VStack {
            VStack{
                if !(viewModel.image == nil){
                    HStack {
                        Spacer()
                        Button {
                            viewModel.showPicker.toggle()
                        } label: {
                            Text("Re-upload a different image")
                            HStack{
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .opacity(0.15)
                            }
                            .padding(.trailing)
                        }
                    }
                    .font(.footnote)
                }
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 400)
                    //                            .mask{
                    //                                if let maskImage = viewModel.finalOutputImage {
                    //                                    Image(uiImage: maskImage)
                    //                                        .resizable()
                    //                                        .scaledToFit()
                    //                                        .frame(minWidth: 0, maxWidth: .infinity)
                    //                                } else {
                    //                                    EmptyView()
                    //                                }
                    //                            }
                    
                } else {
                    RoundedRectangle(cornerRadius: 15)
                        .opacity(0.15)
                        .overlay {
                            VStack(spacing: 20){
                                Image(systemName: "photo.fill")
                                    .font(.largeTitle)
                                    .bold()
                                
                                Text("Choose a photo or take a photo")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.horizontal)
                        .frame(height: 300)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            showSheet.toggle()
                        }
                        .confirmationDialog("Choose or take a photo", isPresented: $showSheet, titleVisibility: .visible) {
                            Button {
                                viewModel.source = .camera
                                viewModel.showPhotoPicker()
                            } label: {
                                Text("Camera")
                            }
                            
                            Button {
                                viewModel.source = .library
                                viewModel.showPhotoPicker()
                                viewModel.finalOutputImage = nil
                                viewModel.image = nil
                            } label: {
                                Text("Photos")
                            }
                        }
                }
                
            }
            if (viewModel.image == nil){
                HStack {
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .frame(height: 2)
                    
                    Text("OR")
                    
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .frame(height: 2)
                    
                }
                .padding()
                .foregroundColor(.gray)
                .opacity(0.6)
                
                TextField("Please enter link (Optional)", text: $textTotype)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.gray)
                            .opacity(0.15)
                    }
                    .padding(.horizontal)
            }
            Spacer()
            NavigationLink {
                ProcessedImageView(viewModel: viewModel)
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Continue")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(content: {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(.gray)
                                .opacity(0.2)
                        })
                        .padding(.horizontal)
                        .disabled(viewModel.image == nil)
                }
            }
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        viewModel.isLoading = true
                    }
            )
            
        }
        .padding(.vertical)
        .sheet(isPresented: $viewModel.showPicker) {
            ImagePicker(sourceType: viewModel.source == .library ? .photoLibrary : .camera, selectedImage: $viewModel.image)
                .ignoresSafeArea()
        }
        .navigationTitle("New item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                dismiss()
            } label: {
               Text("Cancel")
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseClothesView()
            .environmentObject(ComparingClothesViewModel())
    }
}
