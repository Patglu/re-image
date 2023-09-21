
import SwiftUI

struct ClothingItemGridCell: View {
    var clothingItem: Clothingitem
    
    var body: some View {
        VStack{
            if let image = clothingItem.itemImage.toUIImage(){
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                Text(clothingItem.itemDescription)
                HStack(spacing: 0) {
                    ForEach(clothingItem.colors, id:\.self) { color in
                        Rectangle()
                            .foregroundColor(Color(uiColor: color.hexToUIColor() ?? UIColor()))
                            .frame(height: 10)
                    }
                }
                .padding()
            }
        }
    }
}

struct ClothingItemGridCell_Previews: PreviewProvider {
    static var previews: some View {
        ClothingItemGridCell(clothingItem: Clothingitem())
    }
}
