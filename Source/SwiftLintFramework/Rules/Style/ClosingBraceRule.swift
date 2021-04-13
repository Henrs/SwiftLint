import Foundation
import SourceKittenFramework

public struct ClosingBraceRule: SubstitutionCorrectableRule, ConfigurationProviderRule, AutomaticTestableRule {
    public var configuration = SeverityConfiguration(.warning)

    public init() {}

    public static let description = RuleDescription(
        identifier: "closing_brace",
        name: "Closing Brace Spacing",
        description: "大括号之间不要有任何空格",
        kind: .style,
        nonTriggeringExamples: [
            Example("[].map({ })"),
            Example("[].map(\n  { }\n)")
        ],
        triggeringExamples: [
            Example("[].map({ ↓} )"),
            Example("[].map({ ↓}\t)")
        ],
        corrections: [
            Example("[].map({ ↓} )\n"): Example("[].map({ })\n")
        ]
    )

    public func validate(file: SwiftLintFile) -> [StyleViolation] {
        return violationRanges(in: file).map {
            StyleViolation(ruleDescription: Self.description,
                           severity: configuration.severity,
                           location: Location(file: file, characterOffset: $0.location))
        }
    }

    public func violationRanges(in file: SwiftLintFile) -> [NSRange] {
        return file.match(pattern: "(\\}[ \\t]+\\))", excludingSyntaxKinds: SyntaxKind.commentAndStringKinds)
    }

    public func substitution(for violationRange: NSRange, in file: SwiftLintFile) -> (NSRange, String)? {
        return (violationRange, "})")
    }
}
