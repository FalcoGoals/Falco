//
//  DatePickerViewController.swift
//  Falco
//
//  Created by Gerald on 27/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    var date: NSDate!

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.date = date
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "saveDateSegue" {
//        }
    }
}
