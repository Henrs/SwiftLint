import SourceKittenFramework

public struct EnumCaseAssociatedValuesLengthRule: ASTRule, OptInRule, ConfigurationProviderRule, AutomaticTestableRule {
    public var configuration = SeverityLevelsConfiguration(warning: 5, error: 6)

    public init() {}

    public static let description = RuleDescription(
        identifier: "enum_case_associated_values_count",
        name: "Enum Case Associated Values Count",
        description: "枚举的关联属性应该尽可能的少",
        kind: .metrics,
        nonTriggeringExamples: [
            Example("""
            enum Employee {
                case fullTime(name: String, retirement: Date, designation: String, contactNumber: Int)
                case partTime(name: String, age: Int, contractEndDate: Date)
            }
            """),
            Example("""
            enum Barcode {
                case upc(Int, Int, Int, Int)
            }
            """)
        ],
        triggeringExamples: [
            Example("""
            enum Employee {
                case ↓fullTime(name: String, retirement: Date, age: Int, designation: String, contactNumber: Int)
                case ↓partTime(name: String, contractEndDate: Date, age: Int, designation: String, contactNumber: Int)
            }
            """),
            Example("""
            enum Barcode {
                case ↓upc(Int, Int, Int, Int, Int, Int)
            }
            """)
        ]
    )

    public func validate(
        file: SwiftLintFile,
        kind: SwiftDeclarationKind,
        dictionary: SourceKittenDictionary
    ) -> [StyleViolation] {
        guard kind == .enumelement,
            let keyOffset = dictionary.offset,
            let keyName = dictionary.name,
            let caseNameWithoutParams = keyName.split(separator: "(").first else {
            return []
        }

        var violations: [StyleViolation] = []

        let enumCaseAssociatedValueCount = keyName.split(separator: ":").count - 1

        if enumCaseAssociatedValueCount >= configuration.warning {
            let violationSeverity: ViolationSeverity

            if let errorConfig = configuration.error,
                enumCaseAssociatedValueCount >= errorConfig {
                violationSeverity = .error
            } else {
                violationSeverity = .warning
            }

            let reason = "枚举属性 \(caseNameWithoutParams) 最好最多关联\(configuration.warning)个属性"
                + "当前已关联: \(enumCaseAssociatedValueCount),太多了建议拆分或者考虑下自己的逻辑是不是由问题"
            violations.append(
                StyleViolation(
                    ruleDescription: Self.description,
                    severity: violationSeverity,
                    location: Location(file: file, byteOffset: keyOffset),
                    reason: reason
                )
            )
        }
        return violations
    }
}
