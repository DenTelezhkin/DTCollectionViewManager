//
//  PostCell.swift
//  Example
//
//  Created by Denys Telezhkin on 19.08.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager

struct Post {
    let text: String = lorem((1...13).randomElement() ?? 1)
    
    private static func lorem(_ sentences: Int) -> String {
        [
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus scelerisque ut urna et placerat. ",
            "Fusce eu massa lectus. Sed sodales, neque eu tempor condimentum, nibh nulla maximus ipsum, sed tristique turpis velit sed enim.",
            "Mauris malesuada, metus in pulvinar luctus, nisi risus venenatis lorem, nec commodo sem elit ac mi. ",
            "Aenean ligula nibh, varius id metus non, tempus maximus nunc. Praesent eget ornare metus. ",
            "Ut luctus ac est in tempor. ",
            "Donec rhoncus erat at neque dignissim, id gravida urna dapibus. ",
            "Nunc rutrum consequat ante, eu pretium arcu congue non. ",
            "Aliquam venenatis mattis sollicitudin. ",
            "Maecenas eget convallis tortor. ",
            "Nullam sit amet tellus et elit lacinia porttitor. ",
            "Curabitur laoreet eleifend leo vel hendrerit. ",
            "Pellentesque tempus pharetra augue. ",
            "Cras blandit scelerisque mauris, vitae tempor lacus. ",
        ].prefix(sentences).joined()
    }
}

class PostCell: UICollectionViewListCell, ModelTransfer {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    private var avatarDataTask: URLSessionTask?
    
    func update(with model: Post) {
        textLabel.text = model.text
        guard let url = URL(string: "https://secure.gravatar.com/avatar/thisimagewillnotbefound?s=80&d=wavatar") else { return }
        avatarDataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.avatar.image = image
                }
            }
        }
        avatarDataTask?.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarDataTask?.cancel()
        avatarDataTask = nil
    }
}
