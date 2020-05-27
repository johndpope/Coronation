/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 A type representing the available options for virtual content.
 */


enum VirtualContentType: Int {
    case crown
    case crown1
    case crown2
    case crown3

    static let orderedValues: [VirtualContentType] = [.crown, .crown1, .crown2, .crown3]

    var imageName: String {
        switch self {
        case .crown: return "ic_crown"
        case .crown1: return "ic_crown1"
        case .crown2: return "ic_crown2"
        case .crown3: return "ic_crown3"
        }
    }
}
