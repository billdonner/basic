//
//  subs.swift
//  qdemo
//
//  Created by bill donner on 5/23/24.
//

import SwiftUI

var isIpad: Bool {
  UIDevice.current.systemName == "iPadOS"
}
extension String {
    /// Pads or truncates the string to the specified length.
    ///
    /// - Parameters:
    ///   - length: The target length for the string.
    ///   - padCharacter: The character to use for padding, default is a space.
    /// - Returns: The padded or truncated string.
    func paddedOrTruncated(toLength length: Int, withPadCharacter padCharacter: Character = " ") -> String {
        if self.count < length {
            // Pad the string
            return self + String(repeating: padCharacter, count: length - self.count)
        } else if self.count > length {
            // Truncate the string
            let endIndex = self.index(self.startIndex, offsetBy: length)
            return String(self[..<endIndex])
        } else {
            // The string is already of the desired length
            return self
        }
    }
}
// Function to truncate text to 30 characters
func truncatedText(_ text: String,count: Int ) -> String {
    if text.count > count {
        let index = text.index(text.startIndex, offsetBy: count)
        return String(text[..<index]) + "..."
    } else {
        return text
    }
}


func formatTimeInterval(_ interval: TimeInterval) -> String {
    let seconds = Int(interval) % 60
    return "\(seconds)"
}
func removeString(from array: [String], stringToRemove: String) -> [String] {
  var newArray = array
  if let index = newArray.firstIndex(of: stringToRemove) {
    newArray.remove(at: index)
  }
  return newArray
}
func removeStrings(from array: [String], stringsToRemove: [String]) -> [String] {
  var newArray = array
  for string in stringsToRemove {
    while let index = newArray.firstIndex(of: string) {
      newArray.remove(at: index)
    }
  }
  return newArray
}

func joinWithCommasAnd(_ array: [String]) -> String {
    guard !array.isEmpty else { return "" }
    
    if array.count == 1 {
        return array[0]
    } else if array.count == 2 {
        return "\(array[0]) and \(array[1])"
    } else {
        let allButLastTwo = array.dropLast(2).joined(separator: ", ")
        let lastTwo = "\(array[array.count - 2]) and \(array.last!)"
        return "\(allButLastTwo), \(lastTwo)"
    }
}
extension Array {
  /// Chunks the array into arrays with a maximum size
  func chunked(into size: Int) -> [[Element]] {
    stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}
enum AppIconProvider {
    static func appIcon(in bundle: Bundle = .main) -> String {
       // # 1
        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           //   # 2
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            //  # 3
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           //   # 4
              let iconFileName = iconFiles.last else {
            fatalError("Could not find icons in bundle")
        }
        return iconFileName
    }
}
enum AppVersionProvider {
    static func appVersion(in bundle: Bundle = .main) -> String {
        guard let x = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ,
              let y =  bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            fatalError("CFBundlexxx missing from info dictionary")
        }
        return x + "." + y
    }
}
enum AppNameProvider {
    static func appName(in bundle: Bundle = .main) -> String {
        guard let x = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String else {
            fatalError("CFBundleName missing from info dictionary")
        }
        return x
    }
}
struct AppVersionInformationView: View {
   // # 1
  let name:String
    let versionString: String
    let appIcon: String

    var body: some View {
        //# 1
        HStack(alignment: .center, spacing: 12) {
          // # 2
           VStack(alignment: .leading) {
               Text("App")
                   .bold()
               Text("\(name)")
           }
           .font(.caption)
           .foregroundColor(.primary)
            //# 3
            // App icons can only be retrieved as named `UIImage`s
            // https://stackoverflow.com/a/62064533/17421764
            if let image = UIImage(named: appIcon) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
           // # 4
            VStack(alignment: .leading) {
                Text("Version")
                    .bold()
                Text("v\(versionString)")
            }
            .font(.caption)
            .foregroundColor(.primary)
        }
        //# 5
        .fixedSize()
        //# 6
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("App version \(versionString)")
    }
}


struct AppVersionInformationView_Previews: PreviewProvider {
  static var previews: some View {
    AppVersionInformationView(
        name:AppNameProvider.appName(),
        versionString: AppVersionProvider.appVersion(),
        appIcon: AppIconProvider.appIcon()
    )
  }
}

func dumpAppStorage() {

  @AppStorage("elementWidth") var elementWidth = 100.0
  @AppStorage("shuffleUp")  var shuffleUp = true
  @AppStorage("fontsize")  var fontsize = 24.0
  @AppStorage("padding")  var padding = 2.0
  @AppStorage("border") var  border = 3.0
  
  
 // let t = gameState.topics.compactMap  {$0.isLive ? $0.topic : nil}
  
  print("Dump of AppStorage")
  print("================")

  print("elementWidth ",elementWidth)
  print("shuffleUp ",shuffleUp)
  print("fontsize ",fontsize)
  print("padding ",padding)
  print("border ",border)
  print("================")
}



// MARK: - ColorScheme

fileprivate extension Color {
#if os(macOS)
  typealias SystemColor = NSColor
#else
  typealias SystemColor = UIColor
#endif
  
  var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    
#if os(macOS)
    SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
    // Note that non RGB color will raise an exception, that I don't now how to catch because it is an Objc exception.
#else
    guard SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
      // Pay attention that the color should be convertible into RGB format
      // Colors using hue, saturation and brightness won't work
      return nil
    }
#endif
    
    return (r, g, b, a)
  }
}

extension Color: Codable {
  enum CodingKeys: String, CodingKey {
    case red, green, blue
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let r = try container.decode(Double.self, forKey: .red)
    let g = try container.decode(Double.self, forKey: .green)
    let b = try container.decode(Double.self, forKey: .blue)
    
    self.init(red: r, green: g, blue: b)
  }
  
  public func encode(to encoder: Encoder) throws {
    guard let colorComponents = self.colorComponents else {
      return
    }
    
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(colorComponents.red, forKey: .red)
    try container.encode(colorComponents.green, forKey: .green)
    try container.encode(colorComponents.blue, forKey: .blue)
  }
}

// Helper function to calculate luminance
func calculateLuminance(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
    return 0.299 * red + 0.587 * green + 0.114 * blue
}

// Function with Color argument
func foregroundColorFrom( backgroundColor: Color) -> Color {
    // Convert Color to UIColor to extract components
    let uiColor = UIColor(backgroundColor)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    // Use the helper function to calculate luminance
    let luminance = calculateLuminance(red: red, green: green, blue: blue)
    
    // Return either white or black based on luminance
    return luminance > 0.5 ? Color.black : Color.white
}

// Function with RGB values as arguments
func foregroundColorFrom( red: CGFloat, green: CGFloat, blue: CGFloat) -> Color {
    // Use the helper function to calculate luminance
    let luminance = calculateLuminance(red: red, green: green, blue: blue)
    
    // Return either white or black based on luminance
    return luminance > 0.5 ? Color.black : Color.white
}
