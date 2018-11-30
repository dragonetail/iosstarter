import Eureka

public final class ImageRowCell: PushSelectorCell<UIImage> {
    public override func setup() {
        super.setup()
        
        accessoryType = .none
        editingAccessoryView = .none
        
        //let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        imageView.layer.cornerRadius = 17
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        accessoryView = imageView
        editingAccessoryView = imageView
    }
    
    public override func update() {
        super.update()
        
        selectionStyle = row.isDisabled ? .none : .default
        (accessoryView as? UIImageView)?.image = row.value ?? (row as? ImageRowProtocol)?.placeholderImage
        (editingAccessoryView as? UIImageView)?.image = row.value ?? (row as? ImageRowProtocol)?.placeholderImage
    }
}
