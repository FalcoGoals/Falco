//
//  DatePickerViewController.swift
//  Falco
//
//  Created by Gerald on 27/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

protocol DatePickerDelegate {
    func didSave(date: NSDate)
}

class DatePickerViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    var delegate: DatePickerDelegate!

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveDateSegue" {
            delegate.didSave(datePicker.date)
        }
    }
}
