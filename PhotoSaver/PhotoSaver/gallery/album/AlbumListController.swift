import UIKit
import Photos
import PureLayout

//protocol AlbumListControllerDelegate: class {
//    func albumListController(_ controller: AlbumListController, didSelect album: Album)
//}

class AlbumListController: UIViewController {
    
    lazy var tableView: UITableView = self.makeTableView()
    lazy var blurView: UIVisualEffectView = self.makeBlurView()
    
    var animating: Bool = false
    var expanding: Bool = false
    var selectedIndex: Int = 0
    
    var albums: [Album] = [] {
        didSet {
            selectedIndex = 0
        }
    }
    
    var expandedTopConstraint: NSLayoutConstraint?
    var collapsedTopConstraint: NSLayoutConstraint?
    
//    weak var delegate: AlbumListControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        view.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = blurView
        
        view.addSubview(tableView)
        tableView.register(AlbumCell.self, forCellReuseIdentifier: String(describing: AlbumCell.self))
        
        tableView.autoPinEdgesToSuperviewEdges()
    }
    
    func toggle() {
        guard !animating else { return }
        
        animating = true
        expanding = !expanding
        
        if expanding {
            collapsedTopConstraint?.isActive = false
            expandedTopConstraint?.isActive = true
        } else {
            expandedTopConstraint?.isActive = false
            collapsedTopConstraint?.isActive = true
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.superview?.layoutIfNeeded()
        }, completion: { finished in
            self.animating = false
        })
    }
    
    // MARK: - Controls
    
    func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.rowHeight = 84
        
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }
    
    func makeBlurView() -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        
        return view
    }
}

extension AlbumListController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AlbumCell.self), for: indexPath)
            as! AlbumCell
        
        let album = albums[(indexPath as NSIndexPath).row]
        cell.configure(album)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let album = albums[(indexPath as NSIndexPath).row]
//        delegate?.albumListController(self, didSelect: album)
         eventBus.triggerSelectAlbum(album)
        
        selectedIndex = (indexPath as NSIndexPath).row
        tableView.reloadData()
    }
}

