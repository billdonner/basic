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
        ("Spring Green", "Dark Green", (34, 139, 34), (0, 100, 0)),
        ("Light Yellow", "Gold", (255, 223, 0), (255, 215, 0)),
        ("Light Pink", "Deep Pink", (255, 20, 147), (255, 105, 180)),
        ("Light Blue", "Royal Blue", (65, 105, 225), (0, 0, 139)),
        ("Peach", "Dark Orange", (255, 140, 0), (255, 69, 0)),
        ("Lavender", "Dark Violet", (148, 0, 211), (138, 43, 226)),
        ("Mint", "Dark Green", (0, 100, 0), (0, 128, 0)),
        ("Light Coral", "Crimson", (220, 20, 60), (220, 20, 60)),
        ("Lilac", "Indigo", (75, 0, 130), (153, 50, 204)),
        ("Aqua", "Teal", (0, 128, 128), (0, 128, 128)),
        ("Lemon", "Dark Orange", (255, 140, 0), (255, 140, 0)),
        ("Sky Blue", "Navy", (0, 0, 128), (0, 0, 205))
    ])
    
    static let summer =
    ColorScheme(name: .summer, colors: [
        ("Sky Blue", "Midnight Blue", (25, 25, 112), (25, 25, 112)),
        ("Sand", "Brown", (139, 69, 19), (139, 69, 19)),
        ("Ocean", "Dark Blue", (0, 0, 139), (0, 34, 64)),
        ("Sunset Orange", "Dark Red", (139, 0, 0), (139, 0, 0)),
        ("Seafoam", "Teal", (0, 128, 128), (0, 128, 128)),
        ("Palm Green", "Forest Green", (34, 139, 34), (0, 100, 0)),
        ("Coral", "Crimson", (220, 20, 60), (220, 20, 60)),
        ("Citrus", "Dark Orange", (255, 140, 0), (255, 140, 0)),
        ("Lagoon", "Teal", (0, 128, 128), (0, 128, 128)),
        ("Shell", "Saddle Brown", (139, 69, 19), (139, 69, 19)),
        ("Coconut", "Brown", (139, 69, 19), (139, 69, 19)),
        ("Pineapple", "Orange", (255, 165, 0), (255, 140, 0))
    ])
    
    static let autumn =
    ColorScheme(name: .autumn, colors: [
        ("Burnt Orange", "Dark Orange", (204, 85, 0), (255, 140, 0)),
        ("Golden Yellow", "Dark Goldenrod", (184, 134, 11), (184, 134, 11)),
        ("Crimson Red", "Dark Red", (139, 0, 0), (139, 0, 0)),
        ("Forest Green", "Dark Green", (0, 100, 0), (0, 100, 0)),
        ("Pumpkin", "Orange Red", (255, 69, 0), (255, 69, 0)),
        ("Chestnut", "Saddle Brown", (139, 69, 19), (139, 69, 19)),
        ("Harvest Gold", "Dark Goldenrod", (184, 134, 11), (184, 134, 11)),
        ("Amber", "Dark Orange", (255, 140, 0), (255, 69, 0)),
        ("Maroon", "Dark Red", (139, 0, 0), (139, 0, 0)),
        ("Olive", "Dark Olive Green", (85, 107, 47), (85, 107, 47)),
        ("Russet", "Brown", (165, 42, 42), (165, 42, 42)),
        ("Moss Green", "Dark Olive Green", (85, 107, 47), (85, 107, 47))
    ])
    
    static let winter =
    ColorScheme(name: .winter, colors: [
        ("Ice Blue", "Dark Blue", (0, 0, 139), (0, 0, 139)),
        ("Snow", "Dark Red", (139, 0, 0), (139, 0, 0)),
        ("Midnight Blue", "Alice Blue", (25, 25, 112), (240, 248, 255)),
        ("Frost", "Steel Blue", (70, 130, 180), (70, 130, 180)),
        ("Slate", "Dark Slate Gray", (47, 79, 79), (47, 79, 79)),
        ("Silver", "Dark Gray", (169, 169, 169), (169, 169, 169)),
        ("Pine", "Dark Green", (0, 100, 0), (0, 100, 0)),
        ("Berry", "Dark Red", (139, 0, 0), (139, 0, 0)),
        ("Evergreen", "Dark Green", (0, 100, 0), (0, 100, 0)),
        ("Charcoal", "Gray", (54, 69, 79), (54, 69, 79)),
        ("Storm", "Dark Gray", (119, 136, 153), (119, 136, 153)),
        ("Holly", "Dark Green", (0, 128, 0), (0, 128, 0))
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
                        let textColor = self.contrastingTextColor(for: $0.backrgb)
                        return (bgColor, textColor, UUID())
                    }
                }
                return _mappedColors!
            }

            /// Determines the contrasting text color (black or white) for a given background color.
            private func contrastingTextColor(for rgb: (Double, Double, Double)) -> Color {
                let luminance = 0.299 * rgb.0 + 0.587 * rgb.1 + 0.114 * rgb.2
                return luminance > 186 ? .black : .white
            }
        }
