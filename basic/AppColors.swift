//
//  AppColors.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI
//Must be Observable , not a static struct else
//Generic struct 'EnvironmentObject' requires that 'AppColors' conform to 'ObservableObject'

typealias ColorSpec  = (backname:String, forename:String, backrgb:(Double, Double, Double), forergb:(Double, Double, Double))


enum ColorSchemeName: Int,Codable  {
  case bleak = 0
  case winter
  case spring
  case summer
  case autumn
}

class
AppColors  {

  static func colorForTopicIndex(index:Int,gs:GameState) -> (Color, Color, UUID) {
    return   allSchemes[gs.currentscheme.rawValue].mappedColors[index]
  }

  // Define the color schemes
  static let spring =
  ColorScheme(name: .spring, colors: [
    ("Spring Green", "Dark Green", (144, 238, 144), (0, 100, 0)),
    ("Light Yellow", "Dark Yellow", (255, 255, 224), (255, 215, 0)),
    ("Light Pink", "Hot Pink", (255, 182, 193), (255, 105, 180)),
    ("Light Blue", "Dark Blue", (173, 216, 230), (0, 0, 139)),
    ("Peach", "Orange", (255, 218, 185), (255, 69, 0)),
    ("Lavender", "Blue Violet", (230, 230, 250), (138, 43, 226)),
    ("Mint", "Green", (189, 252, 201), (0, 128, 0)),
    ("Light Coral", "Crimson", (240, 128, 128), (220, 20, 60)),
    ("Lilac", "Dark Orchid", (200, 162, 200), (153, 50, 204)),
    ("Aqua", "Teal", (127, 255, 212), (0, 128, 128)),
    ("Lemon", "Dark Orange", (255, 250, 205), (255, 140, 0)),
    ("Sky Blue", "Royal Blue", (135, 206, 235), (0, 0, 205))
  ])
  static let summer =
  ColorScheme(name: .summer, colors: [
    ("Sky Blue", "Midnight Blue", (135, 206, 235), (25, 25, 112)),
    ("Sand", "Saddle Brown", (194, 178, 128), (139, 69, 19)),
    ("Ocean", "Navy", (28, 107, 160), (0, 34, 64)),
    ("Sunset Orange", "Dark Red", (255, 140, 0), (139, 0, 0)),
    ("Seafoam", "Teal", (70, 240, 220), (0, 128, 128)),
    ("Palm Green", "Forest Green", (76, 187, 23), (0, 100, 0)),
    ("Coral", "Crimson", (255, 127, 80), (220, 20, 60)),
    ("Citrus", "Orange", (255, 235, 59), (255, 160, 0)),
    ("Lagoon", "Teal", (72, 209, 204), (0, 128, 128)),
    ("Shell", "Chocolate", (255, 239, 213), (210, 105, 30)),
    ("Coconut", "Saddle Brown", (255, 248, 220), (139, 69, 19)),
    ("Pineapple", "Dark Orange", (255, 223, 0), (255, 140, 0))
  ])
  static let autumn =
  ColorScheme(name:.autumn, colors: [
    ("Burnt Orange", "Dark Orange", (204, 85, 0), (255, 140, 0)),
    ("Golden Yellow", "Dark Goldenrod", (255, 223, 0), (184, 134, 11)),
    ("Crimson Red", "Dark Red", (220, 20, 60), (139, 0, 0)),
    ("Forest Green", "Dark Green", (34, 139, 34), (0, 100, 0)),
    ("Pumpkin", "Orange Red", (255, 117, 24), (255, 69, 0)),
    ("Chestnut", "Saddle Brown", (149, 69, 53), (139, 69, 19)),
    ("Harvest Gold", "Dark Goldenrod", (218, 165, 32), (184, 134, 11)),
    ("Amber", "Orange Red", (255, 191, 0), (255, 69, 0)),
    ("Maroon", "Dark Red", (128, 0, 0), (139, 0, 0)),
    ("Olive", "Dark Olive Green", (128, 128, 0), (85, 107, 47)),
    ("Russet", "Brown", (128, 70, 27), (165, 42, 42)),
    ("Moss Green", "Dark Olive Green", (173, 223, 173), (85, 107, 47))
  ])
  
  static  let winter =
  ColorScheme(name: .winter, colors: [
    ("Ice Blue", "Dark Blue", (176, 224, 230), (0, 0, 139)),
    ("Snow", "Dark Red", (255, 250, 250), (139, 0, 0)),
    ("Midnight Blue", "Alice Blue", (25, 25, 112), (240, 248, 255)),
    ("Frost", "Steel Blue", (240, 248, 255), (70, 130, 180)),
    ("Slate", "Dark Slate Gray", (112, 128, 144), (47, 79, 79)),
    ("Silver", "Dark Gray", (192, 192, 192), (169, 169, 169)),
    ("Pine", "Light Green", (0, 128, 128), (144, 238, 144)),
    ("Berry", "Light Pink", (139, 0, 0), (255, 182, 193)),
    ("Evergreen", "Light Green", (0, 100, 0), (144, 238, 144)),
    ("Charcoal", "White Smoke", (54, 69, 79), (245, 245, 245)),
    ("Storm", "Dark Gray", (119, 136, 153), (169, 169, 169)),
    ("Holly", "White", (0, 128, 0), (255, 255, 255))
  ])
  static  let bleak =
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
  static let allSchemes = [winter,spring,summer,autumn,bleak]
  
}

  class  ColorScheme {
    internal init(name:ColorSchemeName,colors:[ColorSpec]) {
      self.name = name
      self.colors = colors
    }
    
    let name: ColorSchemeName
    let colors: [ColorSpec]
    var _mappedColors : [(Color, Color, UUID)]? = nil
    /// Maps the colors to SwiftUI Color objects and calculates contrasting text colors.
    var mappedColors: [(Color, Color, UUID)] {
      if _mappedColors == nil {
        _mappedColors =  colors.map {
          let bgColor = Color(red: $0.2.0 / 255, green: $0.2.1 / 255, blue: $0.2.2 / 255)
          let textColor = self.contrastingTextColor(for: $0.2)
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
