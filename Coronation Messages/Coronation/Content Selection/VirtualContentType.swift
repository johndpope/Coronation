/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 A type representing the available options for virtual content.
 */


enum VirtualContentType: Int {
    case crown
    case postMalone
    case cashmeoutside
    case custom

    static let orderedValues: [VirtualContentType] = [.crown, .postMalone, .cashmeoutside]

    var imageName: String {
        switch self {
        case .crown: return "crown"
        case .postMalone: return "postmalone"
        case .cashmeoutside: return "cashmeoutside"
        case .custom: return "cashmeoutside"
        }
    }
}
