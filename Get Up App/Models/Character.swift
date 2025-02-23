/// Extension to add emoji-related properties to the Character type.
extension Character {
    /// Checks if the character is a simple emoji (single scalar value).
    var isSimpleEmoji: Bool {
        return unicodeScalars.count == 1 && unicodeScalars.first?.properties.isEmojiPresentation == true
    }

    /// Checks if the character is combined into an emoji (multiple scalar values).
    var isCombinedIntoEmoji: Bool {
        return unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmojiPresentation == true
    }

    /// Checks if the character is an emoji (either simple or combined).
    var isEmoji: Bool {
        return isSimpleEmoji || isCombinedIntoEmoji
    }
}