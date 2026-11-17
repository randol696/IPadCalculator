import UIKit

final class CalculatorViewController: UIViewController {
    private let engine = CalculatorEngine()
    private let displayLabel = UILabel()
    private var buttonsByTitle = [String: UIButton]()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CalculatorTheme.background
        buildLayout()
        refreshDisplay()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for button in buttonsByTitle.values {
            button.layer.cornerRadius = min(button.bounds.width, button.bounds.height) / 2
        }
    }

    private func buildLayout() {
        displayLabel.textColor = CalculatorTheme.display
        displayLabel.textAlignment = .right
        displayLabel.adjustsFontSizeToFitWidth = true
        displayLabel.minimumScaleFactor = 0.4
        displayLabel.numberOfLines = 1
        displayLabel.font = UIFont.systemFont(ofSize: 96, weight: .thin)
        displayLabel.translatesAutoresizingMaskIntoConstraints = false

        let grid = makeButtonGrid()
        grid.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(displayLabel)
        view.addSubview(grid)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            displayLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 24),
            displayLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 28),
            displayLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -28),
            displayLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            grid.topAnchor.constraint(equalTo: displayLabel.bottomAnchor, constant: 24),
            grid.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            grid.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
            grid.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -24)
        ])
    }

    private func makeButtonGrid() -> UIStackView {
        let rows: [[String]] = [
            ["AC", "±", "%", "÷"],
            ["7", "8", "9", "×"],
            ["4", "5", "6", "−"],
            ["1", "2", "3", "+"],
            ["0", ".", "="]
        ]

        let outer = UIStackView()
        outer.axis = .vertical
        outer.distribution = .fillEqually
        outer.spacing = 12

        for row in rows {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 12

            if row.first == "0" {
                stack.distribution = .fill
                let zero = makeButton(title: "0")
                let dot = makeButton(title: ".")
                let equals = makeButton(title: "=")
                zero.contentHorizontalAlignment = .left
                zero.titleEdgeInsets = UIEdgeInsets(top: 0, left: 36, bottom: 0, right: 0)
                stack.addArrangedSubview(zero)
                stack.addArrangedSubview(dot)
                stack.addArrangedSubview(equals)
                NSLayoutConstraint.activate([
                    zero.widthAnchor.constraint(equalTo: dot.widthAnchor, multiplier: 2, constant: 12),
                    equals.widthAnchor.constraint(equalTo: dot.widthAnchor)
                ])
            } else {
                for title in row {
                    stack.addArrangedSubview(makeButton(title: title))
                }
            }

            outer.addArrangedSubview(stack)
        }

        return outer
    }

    private func makeButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        button.clipsToBounds = true
        button.isExclusiveTouch = true
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        switch title {
        case "AC", "±", "%":
            button.backgroundColor = CalculatorTheme.function
            button.setTitleColor(CalculatorTheme.functionTitle, for: .normal)
        case "÷", "×", "−", "+", "=":
            button.backgroundColor = CalculatorTheme.operatorColor
            button.setTitleColor(.white, for: .normal)
        default:
            button.backgroundColor = CalculatorTheme.number
            button.setTitleColor(.white, for: .normal)
        }

        buttonsByTitle[title] = button
        return button
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal), let key = key(for: title) else { return }
        engine.input(key)
        refreshDisplay()
    }

    private func key(for title: String) -> CalculatorKey? {
        switch title {
        case "0"..."9":
            return .digit(Int(title) ?? 0)
        case ".":
            return .decimal
        case "+":
            return .operation(.add)
        case "−":
            return .operation(.subtract)
        case "×":
            return .operation(.multiply)
        case "÷":
            return .operation(.divide)
        case "=":
            return .equals
        case "AC":
            return .allClear
        case "±":
            return .sign
        case "%":
            return .percent
        default:
            return nil
        }
    }

    private func refreshDisplay() {
        displayLabel.text = engine.displayText
    }
}
