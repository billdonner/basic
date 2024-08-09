import SwiftUI

typealias ColorSpec = (backname: String, forename: String, backrgb: (Double, Double, Double), forergb: (Double, Double, Double))

enum ColorSchemeName: Int, Codable {
    case bleak = 0
    case winter = 1
    case spring = 2
    case summer = 3
    case autumn = 4
}

class AppColors {
    
    static func colorForTopicIndex(index: Int, gs: GameState) -> (Color, Color, UUID) {
        return allSchemes[gs.currentscheme.rawValue].mappedColors[index]
    }
    
    // Define the color schemes
    static let spring =
    ColorScheme(name: .spring, colors: [
        ("Spring Green", "Dark Green", (34, 139, 34), (0, 100, 0)), // Darker
        ("Light Yellow", "Gold", (255, 223, 0), (255, 215, 0)), // Light
        ("Deep Pink", "Hot Pink", (255, 20, 147), (255, 105, 180)), // Light
        ("Light Blue", "Royal Blue", (65, 105, 225), (0, 0, 139)), // Darker
        ("Peach", "Dark Orange", (255, 140, 0), (255, 69, 0)), // Darker
        ("Lavender", "Dark Violet", (148, 0, 211), (138, 43, 226)), // Darker
        ("Mint", "Dark Green", (0, 100, 0), (0, 128, 0)), // Darker
        ("Light Coral", "Crimson", (220, 20, 60), (220, 20, 60)), // Darker
        ("Lilac", "Indigo", (75, 0, 130), (153, 50, 204)), // Darker
        ("Aqua", "Teal", (0, 128, 128), (0, 128, 128)), // Darker
        ("Lemon", "Dark Orange", (255, 140, 0), (255, 140, 0)), // Darker
        ("Sky Blue", "Navy", (0, 0, 128), (0, 0, 205)) // Darker
    ])
    
  static let summer =
  ColorScheme(name: .summer, colors: [
      ("Sky Blue", "Midnight Blue", (135, 206, 235), (25, 25, 112)), // Light
      ("Sunshine Yellow", "Goldenrod", (255, 255, 0), (218, 165, 32)), // Light
      ("Sunset Orange", "Dark Red", (255, 99, 71), (139, 0, 0)), // Light
      ("Ocean Blue", "Navy", (0, 105, 148), (0, 34, 64)), // Darker
      ("Seafoam", "Teal", (70, 240, 220), (0, 128, 128)), // Light
      ("Palm Green", "Forest Green", (34, 139, 34), (0, 100, 0)), // Darker
      ("Coral", "Crimson", (255, 127, 80), (220, 20, 60)), // Light
      ("Citrus", "Orange", (255, 165, 0), (255, 69, 0)), // Darker
      ("Lagoon", "Deep Teal", (72, 209, 204), (0, 128, 128)), // Darker
      ("Shell", "Chocolate", (210, 105, 30), (139, 69, 19)), // Darker
      ("Coconut", "Brown", (139, 69, 19), (139, 69, 19)), // Darker
      ("Pineapple", "Dark Orange", (255, 223, 0), (255, 140, 0)) // Light
  ])
    
    static let autumn =
    ColorScheme(name: .autumn, colors: [
        ("Burnt Orange", "Dark Orange", (204, 85, 0), (255, 140, 0)), // Darker
        ("Golden Yellow", "Dark Goldenrod", (255, 223, 0), (184, 134, 11)), // Light
        ("Crimson Red", "Dark Red", (139, 0, 0), (139, 0, 0)), // Darker
        ("Forest Green", "Dark Green", (0, 100, 0), (0, 100, 0)), // Darker
        ("Pumpkin", "Orange Red", (255, 117, 24), (255, 69, 0)), // Darker
        ("Chestnut", "Saddle Brown", (149, 69, 53), (139, 69, 19)), // Darker
        ("Harvest Gold", "Dark Goldenrod", (218, 165, 32), (184, 134, 11)), // Darker
        ("Amber", "Dark Orange", (255, 191, 0), (255, 69, 0)), // Light
        ("Maroon", "Dark Red", (139, 0, 0), (139, 0, 0)), // Darker
        ("Olive", "Dark Olive Green", (85, 107, 47), (85, 107, 47)), // Darker
        ("Russet", "Brown", (165, 42, 42), (165, 42, 42)), // Darker
        ("Moss Green", "Dark Olive Green", (85, 107, 47), (85, 107, 47)) // Darker
    ])
    
    static let winter =
    ColorScheme(name: .winter, colors: [
        ("Ice Blue", "Dark Blue", (176, 224, 230), (0, 0, 139)), // Light
        ("Snow", "Dark Red", (255, 250, 250), (139, 0, 0)), // Light
        ("Midnight Blue", "Alice Blue", (25, 25, 112), (240, 248, 255)), // Darker
        ("Frost", "Steel Blue", (70, 130, 180), (70, 130, 180)), // Darker
        ("Slate", "Dark Slate Gray", (47, 79, 79), (47, 79, 79)), // Darker
        ("Silver", "Dark Gray", (169, 169, 169), (169, 169, 169)), // Darker
        ("Pine", "Dark Green", (0, 100, 0), (0, 100, 0)), // Darker
        ("Berry", "Dark Red", (139, 0, 0), (139, 0, 0)), // Darker
        ("Evergreen", "Dark Green", (0, 100, 0), (0, 100, 0)), // Darker
        ("Charcoal", "Gray", (54, 69, 79), (54, 69, 79)), // Darker
        ("Storm", "Dark Gray", (119, 136, 153), (119, 136, 153)), // Darker
        ("Holly", "Dark Green", (0, 128, 0), (0, 128, 0)) // Darker
    ])
    
    static let bleak =
    ColorScheme(name: .bleak, colors: [
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255)),
        ("Black", "White", (0,0,0), (255,255,255))
    ])
    
    static let allSchemes = [bleak, winter, spring, summer, autumn]
}

class ColorScheme {
    internal init(name: ColorSchemeName, colors: [ColorSpec]) {
        self.name = name
     self.colors = colors
    }
    
    let name: ColorSchemeName
    let colors: [ColorSpec]
    var _mappedColors: [(Color, Color, UUID)]? = nil
    
    /// Maps the colors to SwiftUI Color objects and calculates contrasting text colors.
    var mappedColors: [(Color, Color, UUID)] {
        if _mappedColors == nil {
            _mappedColors = colors.map {
                let bgColor = Color(red: $0.backrgb.0 / 255, green: $0.backrgb.1 / 255, blue: $0.backrgb.2 / 255)
                let textColor = Self.contrastingTextColor(for: $0.backrgb)
                return (bgColor, textColor, UUID())
            }
        }
        return _mappedColors!
    }
    
    /// Determines the contrasting text color (black or white) for a given background color.
   static func contrastingTextColor(for rgb: (Double, Double, Double)) -> Color {
        let luminance = 0.299 * rgb.0 + 0.587 * rgb.1 + 0.114 * rgb.2
        return luminance > 186 ? .black : .white
    }

}
