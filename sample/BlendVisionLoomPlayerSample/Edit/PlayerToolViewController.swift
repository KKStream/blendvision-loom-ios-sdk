//
//  PlayerToolViewController.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/8/17.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit
import CoreMedia
import BlendVisionLoomPlayer

class PlayerToolViewController: UITableViewController {
    let cellIdentifier = "PlayerToolCellIdentifier"

    lazy var rows = Row.allCases(in: self)
    unowned let player: LoomPlayer

    init(player: LoomPlayer) {
        self.player = player
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapCloseButton))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCloseButton))
        }
        navigationItem.title = "Player Tool"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        let cell = dequeuedCell ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)

        let row = rows[indexPath.row]
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.detail(for: player)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = rows[indexPath.row]
        row.action(for: player, alertHandler: { alert in
            self.presentAlert(alert, animated: true, completion: nil)
        }, reloadHandler: {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        })()
    }
}

// MARK: - Actions
extension PlayerToolViewController {
    @objc func didTapCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Row
extension PlayerToolViewController {
    enum Row {
        static func allCases(in viewController: UIViewController) -> [Row] {
            [
                .play,
                .pause,
                .rewind,
                .forward,
                .previous(viewController: viewController),
                .next(viewController: viewController),
                .seek,
                .mute,
                .unmute,
                .showPlaybackControlsAndProgressBar,
                .hidePlaybackControlsAndProgressBar,
                .enterFullscreen(viewController: viewController),
                .exitFullscreen(viewController: viewController),
                .isBackgroundPlaybackEnabled,
                .preferredForwardBufferDuration
            ]
        }

        case play
        case pause
        case rewind
        case forward
        case previous(viewController: UIViewController)
        case next(viewController: UIViewController)
        case seek
        case mute
        case unmute
        case showPlaybackControlsAndProgressBar
        case hidePlaybackControlsAndProgressBar
        case enterFullscreen(viewController: UIViewController)
        case exitFullscreen(viewController: UIViewController)
        case isBackgroundPlaybackEnabled
        case preferredForwardBufferDuration

        var title: String {
            switch self {
            case .play:
                return "play()"
            case .pause:
                return "pause()"
            case .rewind:
                return "rewind()"
            case .forward:
                return "forward()"
            case .previous:
                return "previous()"
            case .next:
                return "next()"
            case .seek:
                return "seek(to seconds: TimeInterval)"
            case .mute:
                return "mute()"
            case .unmute:
                return "unmute()"
            case .showPlaybackControlsAndProgressBar:
                return "showPlaybackControlsAndProgressBar()"
            case .hidePlaybackControlsAndProgressBar:
                return "hidePlaybackControlsAndProgressBar()"
            case .enterFullscreen:
                return "enterFullscreen(autoRotate: Bool)"
            case .exitFullscreen:
                return "exitFullscreen()"
            case .isBackgroundPlaybackEnabled:
                return "isBackgroundPlaybackEnabled"
            case .preferredForwardBufferDuration:
                return "preferredForwardBufferDuration"
            }
        }

        func detail(for player: LoomPlayer) -> String? {
            switch self {
            case .isBackgroundPlaybackEnabled:
                return player.isBackgroundPlaybackEnabled ? "true" : "false"
            case .preferredForwardBufferDuration:
                return "\(player.preferredForwardBufferDuration)"
            default:
                return nil
            }
        }

        func action(for player: LoomPlayer,
                    alertHandler: @escaping ((UIAlertController) -> Void),
                    reloadHandler: @escaping (() -> Void)) -> (() -> Void) {
            {
                switch self {
                case .play:
                    player.play()
                case .pause:
                    player.pause()
                case .rewind:
                    player.rewind()
                case .forward:
                    player.forward()
                case .previous(let viewController):
                    viewController.dismiss(animated: true, completion: {
                        player.previous()
                    })
                case .next(let viewController):
                    viewController.dismiss(animated: true, completion: {
                        player.next()
                    })
                case .seek:
                    alertHandler(
                        .textFieldAlert(title: "",
                                        message: title,
                                        textFieldConfigurationHandler: { textField in
                                            textField.placeholder = "seconds"
                                            textField.clearButtonMode = .whileEditing
                                            textField.keyboardType = .numberPad
                                        },
                                        doneActionEnabledPredicate: { !($0 ?? "").isEmpty },
                                        doneActionHandler: { _, text in
                                            guard let secondsString = text,
                                                  let seconds = TimeInterval(secondsString)
                                            else { return }
                                            player.seek(to: seconds)
                                        })
                    )
                case .mute:
                    player.mute()
                case .unmute:
                    player.unmute()
                case .showPlaybackControlsAndProgressBar:
                    player.showPlaybackControlsAndProgressBar()
                case .hidePlaybackControlsAndProgressBar:
                    player.hidePlaybackControlsAndProgressBar()
                case .enterFullscreen(let viewController):
                    alertHandler(
                        .actionSheet(title: title, message: nil, actions: [
                            UIAlertAction(title: "autoRotate: true", style: .default, handler: { _ in
                                viewController.dismiss(animated: true, completion: {
                                    player.enterFullscreen(autoRotate: true)
                                })
                            }),
                            UIAlertAction(title: "autoRotate: false", style: .default, handler: { _ in
                                viewController.dismiss(animated: true, completion: {
                                    player.enterFullscreen(autoRotate: false)
                                })
                            }),
                            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        ])
                    )
                case .exitFullscreen(let viewController):
                    viewController.dismiss(animated: true, completion: {
                        player.exitFullscreen()
                    })
                case .isBackgroundPlaybackEnabled:
                    alertHandler(
                        .actionSheet(title: title, message: nil, actions: [
                            UIAlertAction(title: "true", style: .default, handler: { _ in
                                player.isBackgroundPlaybackEnabled = true
                                reloadHandler()
                            }),
                            UIAlertAction(title: "false", style: .default, handler: { _ in
                                player.isBackgroundPlaybackEnabled = false
                                reloadHandler()
                            }),
                            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        ])
                    )
                case .preferredForwardBufferDuration:
                    var bufferedEndTime: String {
                        guard let avplayer = player.controller.playbackHandler.player.playerLayer.player,
                              let playingItem = avplayer.currentItem,
                              let loadedTimeRange = playingItem.loadedTimeRanges.first
                        else {
                            return "nil"
                        }
                        return CMTimeGetSeconds(loadedTimeRange.timeRangeValue.end).formattedString()
                    }
                    alertHandler(
                        .textFieldAlert(title: "",
                                        message: title + "\nbuffered till: \(bufferedEndTime)",
                                        textFieldConfigurationHandler: { textField in
                                            textField.placeholder = "seconds"
                                            textField.clearButtonMode = .whileEditing
                                            textField.keyboardType = .numberPad
                                        },
                                        doneActionEnabledPredicate: { !($0 ?? "").isEmpty },
                                        doneActionHandler: { _, text in
                                            guard let secondsString = text,
                                                  let seconds = TimeInterval(secondsString)
                                            else { return }
                                            player.preferredForwardBufferDuration = seconds
                                            reloadHandler()
                                        })
                    )
                }
            }
        }
    }
}
