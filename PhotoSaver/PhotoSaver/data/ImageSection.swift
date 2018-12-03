import Foundation

class ImageSection {
    let title: String
    
    var images = [Image]()
    var count: Int  = 0
    
    init(_ sectionModel: SectionModel) {
        self.title = sectionModel.title
    }
}
