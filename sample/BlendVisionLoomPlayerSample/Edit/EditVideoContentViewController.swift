//
//  EditVideoContentViewController.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/8/19.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit
import BlendVisionLoomPlayer

class EditVideoContentViewController: UITableViewController {
    let cellIdentifier = "VideoContentCellIdentifier"

    let sections = Section.allCases
    let shadowVideoContent = ShadowVideoContent()

    var didUpdateVideoContentHandler: ((VideoContent) -> ())?

    private var shouldEnableDoneButton: Bool {
        shadowVideoContent.toVideoContent() != nil
    }

    init(content: VideoContent? = nil) {
        super.init(nibName: nil, bundle: nil)

        if let content = content {
            shadowVideoContent.fill(with: content)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton))
        navigationItem.rightBarButtonItem?.isEnabled = shouldEnableDoneButton

        navigationItem.title = "Edit Video Content"

        if #available(iOS 13.0, *) {} else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCloseButton))
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows(in: sections[section]).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        let cell = dequeuedCell ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)

        let section = sections[indexPath.section]
        let row = rows(in: section)[indexPath.row]

        cell.textLabel?.text = row.title

        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.minimumScaleFactor = 0.5
        cell.detailTextLabel?.text = row.detail(for: shadowVideoContent)

        cell.accessoryType = row.accessoryType

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = sections[indexPath.section]
        let row = rows(in: section)[indexPath.row]

        row.action(content: shadowVideoContent, alertHandler: { alert in
            self.presentAlert(alert, animated: true, completion: nil)
        }, reloadHandler: {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            self.navigationItem.rightBarButtonItem?.isEnabled = self.shouldEnableDoneButton
        }, pushHandler: { controller in
            self.navigationController?.pushViewController(controller, animated: true)
        })()
    }

    private func rows(in section: Section) -> [Row] {
        switch section {
        case .content:
            return [.id, .title, .startTime]
        case .source:
            return [.sourceUrl, .sourceThumbnailUrl]
        case .drm:
            return [.drmLicenseUrl, .drmCertificateUrl, .drmHeader]
        }
    }
}

// MARK: - Actions
extension EditVideoContentViewController {
    @objc func didTapDoneButton(_ sender: UIBarButtonItem) {
        guard let content = shadowVideoContent.toVideoContent() else { return }
        didUpdateVideoContentHandler?(content)
    }

    @objc func didTapCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Models
extension EditVideoContentViewController {
    enum Section: CaseIterable {
        case content
        case source
        case drm

        var title: String? {
            switch self {
            case .content: return nil
            case .source: return "Source"
            case .drm: return "DRM"
            }
        }
    }
    enum Row: CaseIterable {
        // content
        case id
        case title
        case startTime

        // source
        case sourceUrl
        case sourceThumbnailUrl

        // drm
        case drmLicenseUrl
        case drmCertificateUrl
        case drmHeader

        var title: String? {
            switch self {
            case .id: return "ID"
            case .title: return "Title"
            case .startTime: return "Start Time (ms)"
            case .sourceUrl: return "URL"
            case .sourceThumbnailUrl: return "Thumbnail URL"
            case .drmLicenseUrl: return "License URL"
            case .drmCertificateUrl: return "Certificate URL"
            case .drmHeader: return "Header"
            }
        }

        func detail(for content: ShadowVideoContent) -> String? {
            switch self {
            case .id: return content.id
            case .title: return content.title
            case .startTime: return content.startTime
            case .sourceUrl: return content.sourceUrl
            case .sourceThumbnailUrl: return content.sourceThumbnailUrl
            case .drmLicenseUrl: return content.drmLicenseUrl
            case .drmCertificateUrl: return content.drmCertificateUrl
            case .drmHeader: return "\(content.drmHeader.count) pair(s)"
            }
        }

        var accessoryType: UITableViewCell.AccessoryType {
            switch self {
            case .drmHeader: return .disclosureIndicator
            default: return .none
            }
        }

        func action(content: ShadowVideoContent,
                    alertHandler: @escaping ((UIAlertController) -> Void),
                    reloadHandler: @escaping (() -> Void),
                    pushHandler: @escaping ((UIViewController) -> Void)) -> (() -> Void) {
            {
                switch self {
                case .id:
                    alertHandler(
                        .textFieldAlert(title: "",
                                        message: title,
                                        textFieldConfigurationHandler: { textField in
                                            textField.text = content.id
                                            textField.placeholder = "Required."
                                            textField.clearButtonMode = .whileEditing
                                        },
                                        doneActionEnabledPredicate: { !($0 ?? "").isEmpty },
                                        doneActionHandler: { _, text in
                                            guard let newId = text else { return }
                                            content.id = newId
                                            reloadHandler()
                                        })
                    )
                case .title:
                    alertHandler(
                        .textFieldAlert(title: "",
                                        message: title,
                                        textFieldConfigurationHandler: { textField in
                                            textField.text = content.title
                                            textField.placeholder = "Required."
                                            textField.clearButtonMode = .whileEditing
                                        },
                                        doneActionHandler: { _, text in
                                            guard let newTitle = text else { return }
                                            content.title = newTitle
                                            reloadHandler()
                                        })
                    )
                case .startTime:
                    alertHandler(
                        .textFieldAlert(title: "",
                                        message: title,
                                        textFieldConfigurationHandler: { textField in
                                            textField.text = content.startTime
                                            textField.placeholder = "Required."
                                            textField.clearButtonMode = .whileEditing
                                            textField.keyboardType = .numberPad
                                        },
                                        doneActionEnabledPredicate: { text in
                                            guard let text = text else { return false }
                                            return !text.isEmpty && TimeInterval(text) != nil
                                        },
                                        doneActionHandler: { _, text in
                                            guard let newStartTime = text else { return }
                                            content.startTime = newStartTime
                                            reloadHandler()
                                        })
                    )
                case .sourceUrl:
                    alertHandler(
                        .textFieldAlert(title: "",
                                        message: title,
                                        textFieldConfigurationHandler: { textField in
                                            textField.text = content.sourceUrl
                                            textField.placeholder = "Required."
                                            textField.clearButtonMode = .whileEditing
                                        },
                                        doneActionEnabledPredicate: { text in
                                            guard let text = text else { return false }
                                            return !text.isEmpty && URL(string: text) != nil
                                        },
                                        doneActionHandler: { _, text in
                                            guard let newSourceUrl = text else { return }
                                            content.sourceUrl = newSourceUrl
                                            reloadHandler()
                                        })
                    )
                case .sourceThumbnailUrl:
                    alertHandler(
                        .textFieldAlert(title: "",
                                        message: title,
                                        textFieldConfigurationHandler: { textField in
                                            textField.text = content.sourceThumbnailUrl
                                            textField.placeholder = "Required."
                                            textField.clearButtonMode = .whileEditing
                                        },
                                        doneActionEnabledPredicate: { text in
                                            guard let text = text else { return false }
                                            return !text.isEmpty && URL(string: text) != nil
                                        },
                                        doneActionHandler: { _, text in
                                            guard let newSourceThumbnailUrl = text else { return }
                                            content.sourceThumbnailUrl = newSourceThumbnailUrl
                                            reloadHandler()
                                        })
                    )
                case .drmLicenseUrl:
                    alertHandler(
                        .textFieldAlert(title: "",
                                        message: title,
                                        textFieldConfigurationHandler: { textField in
                                            textField.text = content.drmLicenseUrl
                                            textField.clearButtonMode = .whileEditing
                                        },
                                        doneActionEnabledPredicate: { text in
                                            if let text = text, !text.isEmpty, URL(string: text) == nil { return false }
                                            return true
                                        },
                                        doneActionHandler: { _, text in
                                            guard let newDrmLicenseUrl = text else { return }
                                            content.drmLicenseUrl = newDrmLicenseUrl
                                            reloadHandler()
                                        })
                    )
                case .drmCertificateUrl:
                    alertHandler(
                        .textFieldAlert(title: "",
                                        message: title,
                                        textFieldConfigurationHandler: { textField in
                                            textField.text = content.drmCertificateUrl
                                            textField.clearButtonMode = .whileEditing
                                        },
                                        doneActionEnabledPredicate: { text in
                                            if let text = text, !text.isEmpty, URL(string: text) == nil { return false }
                                            return true
                                        },
                                        doneActionHandler: { _, text in
                                            guard let newDrmCertificateUrl = text else { return }
                                            content.drmCertificateUrl = newDrmCertificateUrl
                                            reloadHandler()
                                        })
                    )
                case .drmHeader:
                    pushHandler(
                        {
                            let controller = EditDrmHeaderViewController(header: content.drmHeader)
                            controller.didUpdateHeaderHandler = { header in
                                content.drmHeader = header
                                reloadHandler()
                            }
                            return controller
                        }()
                    )
                }
            }
        }
    }
}
