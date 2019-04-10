import RxCocoa

public enum YQReachable {
    case reachable(Reachability)
    case unreachable(Reachability)
}

public class YQReachability {
    public static let shared = YQReachability()
    public let reachability = Reachability()!
    public let reachable = BehaviorRelay<YQReachable?>(value: nil)
    public let clickEvent = BehaviorRelay<Int?>(value: nil)
    private var image: UIImage?
    private var text: String?
    private var click: String?
    
    private init() {}
    public func configure(image: UIImage? = nil, text: String? = "网络连接失败，请检查设置", click: String? = nil ) {
        self.image = image
        self.text = text
        self.click = click
        reachability.whenReachable = { [weak self] reachability in
            guard let self = self else {return}
            self.reachable.accept(.reachable(reachability))
        }
        reachability.whenUnreachable = {[weak self] reachability in
            guard let self = self else {return}
            self.reachable.accept(.unreachable(reachability))
        }
    }
    
    public var tipView: UIView {
        var views: [UIView] = []
        if let image = image {
            let view = UIImageView(image: image)
            view.sizeToFit()
            views.append(view)
        }
        if let text = text {
            let view = UILabel()
            view.text = text
            view.sizeToFit()
        }
        let tag = Int.random(in: 10000 ... 99999)
        if let click = click {
            let view = UIButton(type: .custom)
            view.tag = tag
            view.setTitle(click, for: .normal)
            view.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
            view.sizeToFit()
        }
        let view = UIStackView(arrangedSubviews: views)
        view.tag = tag
        return view
    }
    
    public func startNotifier() {
        do {
            try reachability.startNotifier()
        } catch {
            print("网络监测无法启动")
        }
    }
    
    public func stopNotifier() {
        reachability.stopNotifier()
    }
    
    @objc func clickAction(_ sender: UIButton) {
        clickEvent.accept(sender.tag)
    }
}
