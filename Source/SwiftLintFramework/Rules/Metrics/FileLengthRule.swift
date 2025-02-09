import SourceKittenFramework

public struct FileLengthRule: ConfigurationProviderRule {
    public var configuration = FileLengthRuleConfiguration(warning: 400, error: 1000)

    public init() {}

    public static let description = RuleDescription(
        identifier: "file_length",
        name: "File Length",
        description: "一个文件最好也不要太长了.",
        kind: .metrics,
        nonTriggeringExamples: [
            Example(repeatElement("print(\"swiftlint\")\n", count: 400).joined())
        ],
        triggeringExamples: [
            Example(repeatElement("print(\"swiftlint\")\n", count: 401).joined()),
            Example((repeatElement("print(\"swiftlint\")\n", count: 400) + ["//\n"]).joined())
        ]
    )

    public func validate(file: SwiftLintFile) -> [StyleViolation] {
        func lineCountWithoutComments() -> Int {
            let commentKinds = SyntaxKind.commentKinds
            let lineCount = file.syntaxKindsByLines.filter { kinds in
                return !Set(kinds).isSubset(of: commentKinds)
            }.count
            return lineCount
        }

        var lineCount = file.lines.count
        let hasViolation = configuration.severityConfiguration.params.contains {
            $0.value < lineCount
        }

        if hasViolation && configuration.ignoreCommentOnlyLines {
            lineCount = lineCountWithoutComments()
        }

        for parameter in configuration.severityConfiguration.params where lineCount > parameter.value {
            let reason = "一个文件最好不要超过 \(configuration.severityConfiguration.warning) 行代码" +
                         "当前 \(lineCount)行,是不是可以分成多个文件? 多个类?"
            return [StyleViolation(ruleDescription: Self.description,
                                   severity: parameter.severity,
                                   location: Location(file: file.path, line: lineCount),
                                   reason: reason)]
        }

        return []
    }
}
