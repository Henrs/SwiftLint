import SourceKittenFramework

public struct FunctionBodyLengthRule: ASTRule, ConfigurationProviderRule {
    public var configuration = SeverityLevelsConfiguration(warning: 40, error: 100)

    public init() {}

    public static let description = RuleDescription(
        identifier: "function_body_length",
        name: "Function Body Length",
        description: "函数主体最好不要太长了.",
        kind: .metrics
    )

    public func validate(file: SwiftLintFile, kind: SwiftDeclarationKind,
                         dictionary: SourceKittenDictionary) -> [StyleViolation] {
        guard let input = RuleInput(file: file, kind: kind, dictionary: dictionary) else {
            return []
        }

        for parameter in configuration.params {
            let (exceeds, lineCount) = file.exceedsLineCountExcludingCommentsAndWhitespace(
                input.startLine, input.endLine, parameter.value
            )
            guard exceeds else { continue }
            return [
                StyleViolation(
                    ruleDescription: Self.description, severity: parameter.severity,
                    location: Location(file: file, byteOffset: input.offset),
                    reason: """
                        函数主题最好不要超过 \(configuration.warning) 行,不包括空白和换行,当前:\(lineCount) 行,要不要考虑拆分方法
                        """
                )
            ]
        }

        return []
    }
}

private struct RuleInput {
    let offset: ByteCount
    let startLine: Int
    let endLine: Int

    init?(file: SwiftLintFile, kind: SwiftDeclarationKind, dictionary: SourceKittenDictionary) {
        guard SwiftDeclarationKind.functionKinds.contains(kind),
            let offset = dictionary.offset,
            let bodyOffset = dictionary.bodyOffset,
            let bodyLength = dictionary.bodyLength,
            case let contentsNSString = file.stringView,
            let startLine = contentsNSString.lineAndCharacter(forByteOffset: bodyOffset)?.line,
            let endLine = contentsNSString.lineAndCharacter(forByteOffset: bodyOffset + bodyLength)?.line
        else {
            return nil
        }

        self.offset = offset
        self.startLine = startLine
        self.endLine = endLine
    }
}
