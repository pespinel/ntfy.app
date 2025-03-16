enum ApiError: Error, Equatable {
    case unauthorized
    case networkError(String)
    case unknown
    case jsonParsingError(String)

    static func == (lhs: ApiError, rhs: ApiError) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorized, .unauthorized):
            return true
        case (.networkError(let lhsMessage), .networkError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.unknown, .unknown):
            return true
        case (.jsonParsingError(let lhsMessage), .jsonParsingError(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
