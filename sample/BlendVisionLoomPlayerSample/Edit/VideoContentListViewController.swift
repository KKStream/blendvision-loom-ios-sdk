//
//  VideoContentListViewController.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/8/19.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit
import BlendVisionLoomPlayer

class VideoContentListViewController: UITableViewController {
    let cellIdentifier = "VideoContentCellIdentifier"
    private(set) var contents: [VideoContent] {
        didSet {
            didUpdateVideoContentListHandler?(contents)
        }
    }

    var didUpdateVideoContentListHandler: (([VideoContent]) -> Void)?

    init(contents: [VideoContent]) {
        self.contents = contents
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.title = "Video Contents"

        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = contents[indexPath.row].title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let editViewController = EditVideoContentViewController(content: contents[indexPath.row])
        editViewController.didUpdateVideoContentHandler = { [weak self] videoContent in
            self?.contents[indexPath.row] = videoContent
            self?.dismiss(animated: true, completion: {
                self?.tableView.reloadData()
            })
        }
        let navigationController = UINavigationController(rootViewController: editViewController)
        present(navigationController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        contents.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            contents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Actions
extension VideoContentListViewController {
    @objc func didTapAddButton(_ sender: UIBarButtonItem) {
        let editViewController = EditVideoContentViewController()
        editViewController.didUpdateVideoContentHandler = { [weak self] videoContent in
            self?.contents.append(videoContent)
            self?.dismiss(animated: true, completion: {
                self?.tableView.reloadData()
            })
        }
        let navigationController = UINavigationController(rootViewController: editViewController)
        present(navigationController, animated: true, completion: nil)
    }
}
