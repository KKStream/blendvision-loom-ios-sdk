//
//  SingleRowSectionTableViewController.swift
//  BVPlayerSDKSample
//
//  Created by chantil on 2021/8/26.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit

protocol SingleRowSection: CaseIterable where AllCases.Index == Int {
    var rowTitle: String? { get }
    var footerTitle: String? { get }
    var rowAccessoryType: UITableViewCell.AccessoryType { get }
    var rowAction: ((UIViewController) -> Void)? { get }
}

class SingleRowSectionTableViewController<Section: SingleRowSection>: UITableViewController {
    let cellIdentifier = "CellIdentifier"
    let sections = Section.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].rowTitle
        cell.accessoryType = sections[indexPath.section].rowAccessoryType
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footerTitle
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.section].rowAction?(self)
    }
}
