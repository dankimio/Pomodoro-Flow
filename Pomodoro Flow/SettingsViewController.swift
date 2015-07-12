//
//  SettingsViewController.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-06.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, PickerViewControllerDelegate {

    @IBOutlet weak var tickingSoundSwitch: UISwitch!
    @IBOutlet weak var startBreaksSwitch: UISwitch!
    @IBOutlet weak var startPomodorosSwitch: UISwitch!
    
    
    @IBOutlet weak var pomodoroLengthLabel: UILabel!
    @IBOutlet weak var shortBreakLengthLabel: UILabel!
    @IBOutlet weak var longBreakLengthLabel: UILabel!
    @IBOutlet weak var targetPomodorosLabel: UILabel!
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let settings = SettingsManager.sharedManager

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSwitches()
        setupLabels()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let selectedIndexPath = tableView.indexPathForSelectedRow
        if let indexPath = selectedIndexPath {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    private func setupSwitches() {
        tickingSoundSwitch.on = settings.tickingSound
        startBreaksSwitch.on = settings.startBreaks
        startPomodorosSwitch.on = settings.startPomodoros
    }
    
    private func setupLabels() {
        pomodoroLengthLabel.text = "\(settings.pomodoroLength) minutes"
        shortBreakLengthLabel.text = "\(settings.shortBreakLength) minutes"
        longBreakLengthLabel.text = "\(settings.longBreakLength) minutes"
        targetPomodorosLabel.text = "\(settings.targetPomodoros) pomodoros"
    }
    
    @IBAction func toggleTickingSound(sender: UISwitch) {
        print("Ticking sound: \(sender.on)")
        settings.tickingSound = sender.on
    }

    @IBAction func toggleStartBreaks(sender: UISwitch) {
        print("Automatically start breaks: \(sender.on)")
        settings.startBreaks = sender.on
    }
    
    @IBAction func toggleStartPomodoros(sender: UISwitch) {
        print("Automatically start pomodoros: \(sender.on)")
        settings.startPomodoros = sender.on
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let picker = segue.destinationViewController as? PickerViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "PomodoroLengthPicker":
                    picker.selectedValue = settings.pomodoroLength
                    picker.type = PickerType.PomodoroLength
                case "ShortBreakLengthPicker":
                    picker.selectedValue = settings.shortBreakLength
                    picker.type = PickerType.ShortBreakLength
                case "LongBreakLengthPicker":
                    picker.selectedValue = settings.longBreakLength
                    picker.type = PickerType.LongBreakLength
                case "TargetPomodorosPicker":
                    picker.specifier = "pomodoros"
                    picker.selectedValue = settings.targetPomodoros
                    picker.type = PickerType.TargetPomodoros
                default:
                    break
                }
                picker.delegate = self
            }
        }
    }
    
    func pickerDidFinishPicking(picker: PickerViewController) {
        setupLabels()
    }

}