import LTMorphingLabel

fileprivate func shouldContinueToEnlarge(targetSize: CGSize, currentSize: CGSize) -> Bool {
    return targetSize.height > currentSize.height && targetSize.width > currentSize.width
}

func fontSizeThatFits(size: CGSize, text: NSString, font: UIFont) -> CGFloat {
    var fontToTest = font.withSize(0)
    var currentSize = text.size(withAttributes: [NSAttributedString.Key.font: fontToTest])
    var fontSize = CGFloat(1)
    while shouldContinueToEnlarge(targetSize: size, currentSize: currentSize) {
        fontToTest = fontToTest.withSize(fontSize)
        currentSize = text.size(withAttributes: [NSAttributedString.Key.font: fontToTest])
        fontSize += 1
    }
    return fontSize - 1
}

extension LTMorphingLabel {
    func updateFontSizeToFit(size: CGSize, multiplier: CGFloat = 0.9) {
        let font = (textAttributes?[.font] as? UIFont) ?? self.font
        let fontSize = fontSizeThatFits(size: size, text: (text ?? "a") as NSString, font: font!.withSize(16)) * multiplier
        textAttributes = [.font: font!.withSize(fontSize)]
        self.font = font!.withSize(fontSize)
    }
    
    func updateFontSizeToFit() {
        updateFontSizeToFit(size: bounds.size)
    }
}

extension String {
    var localised: String {
        NSLocalizedString(self, comment: "")
    }
}
