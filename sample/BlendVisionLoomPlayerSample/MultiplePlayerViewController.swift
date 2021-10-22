//
//  MultiplePlayerViewController.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/8/29.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit
import BlendVisionLoomPlayer

class MultiplePlayerViewController: UIViewController {
    let scrollView: UIScrollView = UIScrollView()
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let players: [LoomPlayer]

    init(players: [LoomPlayer]) {
        self.players = players
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        scrollView.backgroundColor = .white
        stackView.backgroundColor = .white
        scrollView.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var index = 0
        for player in players {
            player.view.heightAnchor.constraint(equalToConstant: CGFloat(200 + index * 100)).isActive = true
            index += 1
            stackView.addArrangedSubview(player.view)
        }
    }
}
