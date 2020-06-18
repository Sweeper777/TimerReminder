import UIKit

class AnalogClockView: UIView {
    
    var labels = [UILabel]()
    
    var dateComponents: DateComponents!
    var displayLink: CADisplayLink!
    
    var clockFrame: CGRect {
        if width > height {
            return CGRect(x: (width - height) / 2, y: 0, width: height, height: height)
                .insetBy(dx: clockSize * borderWidthScale / 2, dy: clockSize * borderWidthScale / 2)
        } else {
            return CGRect(x: 0, y: (height - width) / 2, width: width, height: width)
                .insetBy(dx: clockSize * borderWidthScale / 2, dy: clockSize * borderWidthScale / 2)
        }
    }
    
    var clockSize: CGFloat {
        min(width, height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        labels.append(contentsOf: (1...12).map {
            let label = UILabel()
            label.text = "\($0)"
            return label
        })
        labels.forEach(self.addSubview(_:))
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink.add(to: .main, forMode: .common)
    }
    
    @objc func updateDisplay() {
        let newDateComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute, .second], from: Date())
        if dateComponents == nil || newDateComponents != dateComponents {
            dateComponents = newDateComponents
            setNeedsDisplay()
        }
    }
    
    struct HandInfo {
        let longRadius: CGFloat
        let shortRadius: CGFloat
        let widthScale: CGFloat
    }
    
    let digitsInset = 0.3.f
    let fontScale = 0.1.f
    let borderWidthScale = 0.014.f
    let thinMarkingInset = 0.1.f
    let thickMarkingInset = 0.16.f
    let thinMarkingWidthScale = 0.01.f
    let thickMarkingWidthScale = 0.014.f
    let secondHand = HandInfo(longRadius: 0.9, shortRadius: 0.1, widthScale: 0.01)
    let minuteHand = HandInfo(longRadius: 0.85, shortRadius: 0.095, widthScale: 0.02)
    let hourHand = HandInfo(longRadius: 0.5, shortRadius: 0.05, widthScale: 0.03)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: clockFrame.midX, y: clockFrame.midY)
        let radius = clockSize * (1 - digitsInset) / 2
        for (label, angle) in zip(labels, stride(from: CGFloat.pi / -3, to: 5 * .pi / 3, by: .pi / 6)) {
            label.font = UIFont.monospacedDigitSystemFont(ofSize: clockSize * fontScale, weight: .regular)
            label.sizeToFit()
            label.center = center.applying(CGAffineTransform(translationX: radius * cos(angle), y: radius * sin(angle)))
        }
    }
    
    override func draw(_ rect: CGRect) {
        let clockBorder = UIBezierPath(ovalIn: clockFrame)
        clockBorder.lineWidth = borderWidthScale * clockSize
        UIColor.label.setStroke()
        clockBorder.stroke()
        
        let thinMarkingRadius = clockSize * (1 - thinMarkingInset) / 2
        let thickMarkingRadius = clockSize * (1 - thickMarkingInset) / 2
        for i in 0..<60 {
            let angle = i.f * .pi / 30
            if i % 5 == 0 {
                drawMarking(angle: angle, radius: thickMarkingRadius, lineWidth: thickMarkingWidthScale * clockSize)
            } else {
                drawMarking(angle: angle, radius: thinMarkingRadius, lineWidth: thinMarkingWidthScale * clockSize)
            }
        }
        
        guard let dc = dateComponents else { return }
        func calculateHourAngle() -> CGFloat {
            let hourPart = dc.hour!.f / 12.f
            let minutePart = dc.minute!.f / (12 * 60).f
            let secondPart = dc.second!.f / (12 * 3600).f
            return (hourPart + minutePart + secondPart) * 2 * .pi
        }
        let hourAngle = calculateHourAngle()
        drawHand(angle: hourAngle - .pi / 2,
                 longRadius: clockSize * hourHand.longRadius / 2,
                 shortRadius: clockSize * hourHand.shortRadius / 2,
                 lineWidth: clockSize * hourHand.widthScale,
                 color: .label)
        
        func calculateMinuteAngle() -> CGFloat {
            let minutePart = dc.minute!.f / 60.f
            let secondPart = dc.second!.f / 3600.f
            return (minutePart + secondPart) * 2 * .pi
        }
        let minuteAngle = calculateMinuteAngle()
        drawHand(angle: minuteAngle - .pi / 2,
                 longRadius: clockSize * minuteHand.longRadius / 2,
                 shortRadius: clockSize * minuteHand.shortRadius / 2,
                 lineWidth: clockSize * minuteHand.widthScale,
                 color: .label)
        
        let secondAngle = dc.second!.f / 60 * 2 * .pi
        drawHand(angle: secondAngle - .pi / 2,
                 longRadius: clockSize * secondHand.longRadius / 2,
                 shortRadius: clockSize * secondHand.shortRadius / 2,
                 lineWidth: clockSize * secondHand.widthScale,
                 color: .systemRed)
    }
    
    func drawMarking(angle: CGFloat, radius: CGFloat, lineWidth: CGFloat) {
        let clockFrameRadius = clockFrame.width / 2
        let center = CGPoint(x: clockFrame.midX, y: clockFrame.midY)
        let marking = UIBezierPath()
        marking.move(to: center.applying(
            CGAffineTransform(translationX: radius * cos(angle), y: radius * sin(angle))
        ))
        marking.addLine(to: center.applying(
            CGAffineTransform(translationX: clockFrameRadius * cos(angle), y: clockFrameRadius * sin(angle))
        ))
        marking.lineWidth = lineWidth
        marking.lineCapStyle = .round
        marking.stroke()
    }
    
    func drawHand(angle: CGFloat, longRadius: CGFloat, shortRadius: CGFloat, lineWidth: CGFloat, color: UIColor) {
        let center = CGPoint(x: clockFrame.midX, y: clockFrame.midY)
        let hand = UIBezierPath()
        hand.move(to: center.applying(
            CGAffineTransform(translationX: -shortRadius * cos(angle), y: -shortRadius * sin(angle))
        ))
        hand.addLine(to: center.applying(
            CGAffineTransform(translationX: longRadius * cos(angle), y: longRadius * sin(angle))
        ))
        hand.lineWidth = lineWidth
        hand.lineCapStyle = .round
        color.setStroke()
        hand.stroke()
    }
}
