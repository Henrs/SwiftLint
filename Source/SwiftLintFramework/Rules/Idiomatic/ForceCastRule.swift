import SourceKittenFramework

public struct ForceCastRule: ConfigurationProviderRule, AutomaticTestableRule {
    public var configuration = SeverityConfiguration(.error)

    public init() {}

    public static let description = RuleDescription(
        identifier: "force_cast",
        name: "Force Cast",
        description: "请不要强制解包,请不要强制解包,请不要强制解包!!!,除非你做了明确的空值判断.",
        kind: .idiomatic,
        nonTriggeringExamples: [
            Example("NSNumber() as? Int\n")
        ],
        triggeringExamples: [ Example("NSNumber() ↓as! Int\n") ]
    )

    public func validate(file: SwiftLintFile) -> [StyleViolation] {
        return file.match(pattern: "as!", with: [.keyword]).map {
            StyleViolation(ruleDescription: Self.description,
                           severity: configuration.severity,
                           location: Location(file: file, characterOffset: $0.location))
        }
    }
}
