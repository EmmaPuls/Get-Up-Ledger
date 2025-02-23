import SwiftUI

/// Extension to add utility methods to the String type.
extension String {
    /// Calculates the width of the string when rendered with the specified font.
    /// - Parameter font: The font used to render the string.
    /// - Returns: The width of the rendered string.
    func widthOfString(usingFont font: NSFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
