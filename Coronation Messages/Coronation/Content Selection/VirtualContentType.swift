/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 A type representing the available options for virtual content.
 */


enum VirtualContentType: Int {
    case crown
    case crown2

    static let orderedValues: [VirtualContentType] = [.crown, .crown2]

    var imageName: String {
        switch self {
        case .crown: return "crown"
        case .crown2: return "crown"
        }
    }
}
