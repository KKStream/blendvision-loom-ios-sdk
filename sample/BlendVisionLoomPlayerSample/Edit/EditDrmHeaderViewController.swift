//
//  EditDrmHeaderViewController.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/9/7.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit

class EditDrmHeaderViewController: UITableViewController {
    let cellIdentifier = "DrmHeaderCellIdentifier"

    private(set) var pairs: [(key: String, value: String)] = []

    var didUpdateHeaderHandler: (([String: String]) -> Void)?

    init(header: [String: String]) {
        pairs = header.map({ (key: $0, value: $1) })
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.title = "DRM Header"

        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pairs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text =
            """
            "\(pairs[indexPath.row].key)": "\(pairs[indexPath.row].value)"
            """
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        edit(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            pairs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    private func edit(at index: Int?) {
        let pair: (key: String, value: String)? = index != nil ? pairs[index!] : nil
        let alert = UIAlertController.twoTextFieldAlert(title: "Edit key and value.",
                                                        message: nil,
                                                        firstTextFieldConfigurationHandler: { textField in
                                                            textField.text = pair?.key
                                                            textField.placeholder = "Key (e.g. \"Authorization\")"
                                                            textField.clearButtonMode = .whileEditing
                                                        },
                                                        secondTextFieldConfigurationHandler: { textField in
                                                            textField.text = pair?.value
                                                            textField.placeholder = "Value (e.g. \"Bearer {JWT}\")"
                                                            textField.clearButtonMode = .whileEditing
                                                        },
                                                        doneActionEnabledPredicate: { key, value in
                                                            !(key ?? "").isEmpty && !(value ?? "").isEmpty
                                                        },
                                                        doneActionHandler: { action, key, value in
                                                            guard let key = key, let value = value else { return }
                                                            if let index = index {
                                                                self.pairs[index] = (key: key, value: value)
                                                            } else {
                                                                self.pairs.append((key: key, value: value))
                                                            }
                                                            self.tableView.reloadData()
                                                            self.didUpdateHeaderHandler?(Dictionary(uniqueKeysWithValues: self.pairs))
                                                        })
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Actions
extension EditDrmHeaderViewController {
    @objc func didTapAddButton(_ sender: UIBarButtonItem) {
        edit(at: nil)
    }
}
