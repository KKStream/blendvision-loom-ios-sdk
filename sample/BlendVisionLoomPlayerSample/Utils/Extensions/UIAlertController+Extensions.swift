//
//  UIAlertController+Extensions.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/8/19.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func textFieldAlert(title: String?,
                               message: String?,
                               textFieldConfigurationHandler: ((UITextField) -> Void)? = nil,
                               cancelActionHandler: ((UIAlertAction) -> Void)? = nil,
                               doneActionEnabledPredicate: ((_ text: String?) -> Bool)? = nil,
                               doneActionHandler: ((UIAlertAction, _ text: String?) -> Void)? = nil) -> UIAlertController {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelActionHandler)
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { [unowned alert] alertAction in
            guard let textField = alert.textFields?.first else { return }
            doneActionHandler?(alertAction, textField.text)
        })
        alert.addTextField(configurationHandler: { textField in
            textFieldConfigurationHandler?(textField)
            doneAction.isEnabled = doneActionEnabledPredicate?(textField.text) ?? true

            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main, using: { _ in
                doneAction.isEnabled = doneActionEnabledPredicate?(textField.text) ?? true
            })
        })
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        return alert
    }

    static func twoTextFieldAlert(title: String?,
                                  message: String?,
                                  firstTextFieldConfigurationHandler: ((UITextField) -> Void)? = nil,
                                  secondTextFieldConfigurationHandler: ((UITextField) -> Void)? = nil,
                                  cancelActionHandler: ((UIAlertAction) -> Void)? = nil,
                                  doneActionEnabledPredicate: ((_ firstText: String?, _ secondText: String?) -> Bool)? = nil,
                                  doneActionHandler: ((UIAlertAction, _ firstText: String?, _ secondText: String?) -> Void)? = nil) -> UIAlertController {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelActionHandler)
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { [unowned alert] alertAction in
            guard let firstTextField = alert.textFields?[0], let secondTextField = alert.textFields?[1] else { return }
            doneActionHandler?(alertAction, firstTextField.text, secondTextField.text)
        })
        alert.addTextField(configurationHandler: { [unowned alert] textField in
            firstTextFieldConfigurationHandler?(textField)

            var secondText: String? {
                alert.textFields?.indices.contains(1) == true ? alert.textFields?[1].text : nil
            }
            doneAction.isEnabled = doneActionEnabledPredicate?(textField.text, secondText) ?? true

            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main, using: { _ in
                doneAction.isEnabled = doneActionEnabledPredicate?(textField.text, secondText) ?? true
            })
        })
        alert.addTextField(configurationHandler: { [unowned alert] textField in
            secondTextFieldConfigurationHandler?(textField)

            var firstText: String? {
                alert.textFields?.indices.contains(0) == true ? alert.textFields?[0].text : nil
            }
            doneAction.isEnabled = doneActionEnabledPredicate?(firstText, textField.text) ?? true

            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main, using: { _ in
                doneAction.isEnabled = doneActionEnabledPredicate?(firstText, textField.text) ?? true
            })
        })
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        return alert
    }

    static func actionSheet(title: String?,
                            message: String?,
                            actions: [UIAlertAction] = []) -> UIAlertController {

        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach({ actionSheet.addAction($0) })
        return actionSheet
    }
}
