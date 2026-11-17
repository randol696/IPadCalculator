import Foundation

enum CalculatorKey: Equatable {
    case digit(Int)
    case decimal
    case operation(Operation)
    case equals
    case allClear
    case sign
    case percent

    enum Operation: Equatable {
        case add
        case subtract
        case multiply
        case divide
    }
}

final class CalculatorEngine {
    private(set) var displayText = "0"
    private var currentValue: Double = 0
    private var storedValue: Double?
    private var pendingOperation: CalculatorKey.Operation?
    private var isTyping = false
    private var hasDecimal = false

    func input(_ key: CalculatorKey) {
        switch key {
        case .digit(let digit):
            appendDigit(digit)
        case .decimal:
            appendDecimal()
        case .operation(let operation):
            applyPendingOperation()
            pendingOperation = operation
            storedValue = currentValue
            isTyping = false
            hasDecimal = false
        case .equals:
            applyPendingOperation()
            pendingOperation = nil
            storedValue = nil
            isTyping = false
            hasDecimal = displayText.contains(".")
        case .allClear:
            reset()
        case .sign:
            currentValue = -currentValue
            displayText = format(currentValue)
        case .percent:
            currentValue /= 100
            displayText = format(currentValue)
            isTyping = false
        }
    }

    private func appendDigit(_ digit: Int) {
        if !isTyping || displayText == "0" {
            displayText = String(digit)
            isTyping = true
            hasDecimal = false
        } else if displayText.count < 12 {
            displayText += String(digit)
        }
        currentValue = Double(displayText) ?? 0
    }

    private func appendDecimal() {
        if !isTyping {
            displayText = "0."
            isTyping = true
            hasDecimal = true
            currentValue = 0
            return
        }
        if !hasDecimal {
            displayText += "."
            hasDecimal = true
        }
    }

    private func applyPendingOperation() {
        guard let operation = pendingOperation, let stored = storedValue else { return }

        switch operation {
        case .add:
            currentValue = stored + currentValue
        case .subtract:
            currentValue = stored - currentValue
        case .multiply:
            currentValue = stored * currentValue
        case .divide:
            if currentValue == 0 {
                displayText = "Error"
                resetAfterError()
                return
            }
            currentValue = stored / currentValue
        }

        displayText = format(currentValue)
    }

    private func reset() {
        displayText = "0"
        currentValue = 0
        storedValue = nil
        pendingOperation = nil
        isTyping = false
        hasDecimal = false
    }

    private func resetAfterError() {
        currentValue = 0
        storedValue = nil
        pendingOperation = nil
        isTyping = false
        hasDecimal = false
    }

    private func format(_ value: Double) -> String {
        if value.isNaN || value.isInfinite {
            return "Error"
        }
        if value == 0 {
            return "0"
        }

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
