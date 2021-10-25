//
//  EditPlayerViewController.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/8/27.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit
import BlendVisionLoomPlayer

class EditPlayerViewController: UITableViewController {
    private let configCellIdentifier = "ConfigCell"

    private(set) var handleButton: HandleButton?
    private(set) var barItemEventHandler: BarItemActionHandler?

    let model: LoomPlayerModel

    enum Section: String, CaseIterable {
        case barItems = "Bar Items"
        case contents = "Contents"

        var title: String { rawValue }

        var rows: [Row] {
            switch self {
            case .barItems: return [.settings, .playerTool]
            case .contents: return [.startIndex, .videoContents]
            }
        }
    }
    enum Row: String, CaseIterable {
        // Bar Items
        case airplay = "AirPlay"
        case settings = "Settings"
        case playerTool = "🎮 Player Tool"

        // Contents
        case startIndex = "Start Index"
        case videoContents = "Video Contents"

        var title: String { rawValue }
    }
    private let sections: [Section] = Section.allCases

    var didUpdatePlayerModelHandler: ((LoomPlayerModel) -> ())?

    init(model: LoomPlayerModel? = nil) {
        self.model = model ?? LoomPlayerModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton))

        navigationItem.title = "Edit Player"

        if #available(iOS 13.0, *) {} else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCloseButton))
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: configCellIdentifier)
        let cell = dequeuedCell ?? UITableViewCell(style: .value1, reuseIdentifier: configCellIdentifier)

        let row = sections[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.minimumScaleFactor = 0.5
        cell.detailTextLabel?.text = nil

        switch row {
        case .airplay:
//            if let index = player.context.barItems.firstIndex(of: .airplay) {
//                cell.detailTextLabel?.text = String(index + 1)
//            }
            break
        case .settings:
            if let index = model.context.barItems.firstIndex(of: .settings) {
                cell.detailTextLabel?.text = String(index + 1)
            }
        case .playerTool:
            if let index = model.context.barItems.firstIndex(where: { $0.isHandleButtonItem }) {
                cell.detailTextLabel?.text = String(index + 1)
            }
        case .startIndex:
            cell.detailTextLabel?.text = String(model.startIndex)
        case .videoContents:
            cell.detailTextLabel?.text = String(model.contents.count)
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch sections[indexPath.section].rows[indexPath.row] {
        case .airplay:
//            if let index = player.context.barItems.firstIndex(of: .airplay) {
//                player.context.barItems.remove(at: index)
//            } else {
//                player.context.barItems.append(.airplay)
//            }
//            tableView.reloadData()
            break

        case .settings:
            if let index = model.context.barItems.firstIndex(of: .settings) {
                model.context.barItems.remove(at: index)
            } else {
                model.context.barItems.append(.settings)
            }
            tableView.reloadData()

        case .playerTool:
            if let index = model.context.barItems.firstIndex(where: { $0.isHandleButtonItem }) {
                self.handleButton = nil
                self.barItemEventHandler = nil
                model.context.barItems.remove(at: index)
            } else {
                let barItemEventHandler = BarItemActionHandler()
                let handleButton: HandleButton = {
                    let button = HandleButton()
                    button.addTarget(barItemEventHandler,
                                     action: #selector(barItemEventHandler.didTapHandle),
                                     for: .touchUpInside)
                    return button
                }()
                self.handleButton = handleButton
                self.barItemEventHandler = barItemEventHandler
                model.context.barItems.append(.custom(view: handleButton))
            }
            tableView.reloadData()

        case .startIndex:
            let alert = UIAlertController(title: "Enter Start Index", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let doneAction = UIAlertAction(title: "Done", style: .default, handler: { (_) in
                guard let newStartIndexString = alert.textFields?.first?.text,
                      let newStartIndex = Int(newStartIndexString)
                else { return }
                self.model.startIndex = newStartIndex
                self.tableView.reloadData()
            })
            alert.addTextField(configurationHandler: { textField in
                let shouldBeEnabled: (String?) -> Bool = { !($0 ?? "").isEmpty }

                textField.text = "\(self.model.startIndex)"
                textField.clearButtonMode = .whileEditing
                textField.keyboardType = .numberPad
                doneAction.isEnabled = shouldBeEnabled(textField.text)

                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main, using: { _ in
                    doneAction.isEnabled = shouldBeEnabled(textField.text)
                })
            })
            alert.addAction(cancelAction)
            alert.addAction(doneAction)
            presentAlert(alert, animated: true, completion: nil)
        case .videoContents:
            let videoContentListViewController = VideoContentListViewController(contents: model.contents)
            videoContentListViewController.didUpdateVideoContentListHandler = { [weak self] contents in
                self?.model.contents = contents
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(videoContentListViewController, animated: true)
        }
    }
}

// MARK: - Actions
extension EditPlayerViewController {
    @objc func didTapDoneButton(_ sender: UIBarButtonItem) {
        didUpdatePlayerModelHandler?(model)
    }

    @objc func didTapCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - HandleButton
class HandleButton: UIButton {
    init() {
        super.init(frame: .zero)
        setTitle("🎮", for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - PlayerContext.BarItem Helper
private extension PlayerContext.BarItem {
    var isHandleButtonItem: Bool {
        if case .custom(view: let view?) = self, view.isMember(of: HandleButton.self) {
            return true
        }
        return false
    }
}
