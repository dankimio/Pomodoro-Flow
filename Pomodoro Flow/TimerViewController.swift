//
//  TimerViewController.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-06-24.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!

    // Scheduler
    private var scheduler: Scheduler
    
    // Time
    private var timer: NSTimer?
    private var currentTime: Double!
    private var running = false
    
    // Configuration
    private let rowsPerSection = 7
    private let animationDuration = 0.3
    private let settings = SettingsManager.sharedManager
    
    private struct CollectionViewIdentifiers {
        static let emptyCell = "EmptyCell"
        static let filledCell = "FilledCell"
    }
    
    // Pomodoros view
    private var completedPomodoros = 9
    private var targetPomodoros: Int
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        targetPomodoros = settings.targetPomodoros
        scheduler = Scheduler()
        
        super.init(coder: aDecoder)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "willEnterForeground",
            name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        
        willEnterForeground()
        
        if scheduler.pausedTime != nil {
            animateStarted()
            animatePaused()
        }
    }
    
    func willEnterForeground() {
        print("willEnterForeground called from controller")
        
        if let pausedTime = scheduler.pausedTime {
            currentTime = pausedTime
        } else if let fireDate = scheduler.fireDate {
            print("fireDate: \(fireDate)")
            currentTime = fireDate.timeIntervalSinceDate(NSDate())
            print("currentTime: \(currentTime)")
        } else {
            currentTime = Double(settings.pomodoroLength)
        }
        
        updateTimerLabel()
    }
    
    func secondPassed() {
        if currentTime > 0 {
            currentTime = currentTime - 1.0
        } else {
            stop()
        }
        
        updateTimerLabel()
    }
    
    // MARK: - Actions

    @IBAction func togglePaused(sender: EmptyRoundedButton) {
        scheduler.paused ? unpause() :pause()
    }

    @IBAction func start(sender: RoundedButton) {
        start()
    }
    
    @IBAction func stop(sender: RoundedButton) {
        stop()
    }
    
    func start() {
        scheduler.start()
        running = true
        animateStarted()
        fireTimer()
    }
    
    func stop() {
        scheduler.stop()
        running = false
        animateStopped()
        timer?.invalidate()
        resetCurrentTime()
        updateTimerLabel()
    }
    
    func pause() {
        guard running else { return }

        scheduler.pause(currentTime)
        running = false
        timer?.invalidate()
        animatePaused()
    }
    
    func unpause() {
        scheduler.unpause()
        running = true
        fireTimer()
        animateUnpaused()
    }
    
    func presentAlertFromNotification(notification: UILocalNotification) {
        let alertController = UIAlertController(title: notification.alertTitle,
            message: notification.alertBody, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) { action in
            print("Cancel")
        }
        let okAction = UIAlertAction(title: "Go", style: .Default) { action in
            print("OK")
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    private func updateTimerLabel() {
        let time = Int(currentTime)
        timerLabel.text = String(format: "%02d:%02d", time / 60, time % 60)
    }
    
    private func resetCurrentTime() {
        currentTime = Double(settings.pomodoroLength)
    }
    
    private func fireTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self, selector: "secondPassed", userInfo: nil, repeats: true)
    }
    
    func refreshPomodoros() {
        targetPomodoros = settings.targetPomodoros
        collectionView.reloadData()
    }

    private func numberOfSections() -> Int {
        return Int(ceil(Double(targetPomodoros) / Double(rowsPerSection)))
    }
    
    private func lastSectionIndex() -> Int {
        if numberOfSections() == 0 {
            return 0
        }
        
        return numberOfSections() - 1
    }
    
    private func numberOfRowsInLastSection() -> Int {
        return targetPomodoros % rowsPerSection
    }
    
    private func animateStarted() {
        let deltaY: CGFloat = 54
        buttonContainer.frame.origin.y += deltaY
        buttonContainer.hidden = false
        
        UIView.animateWithDuration(animationDuration) {
            self.startButton.alpha = 0.0
            self.buttonContainer.alpha = 1.0
            self.buttonContainer.frame.origin.y += -deltaY
        }
    }
    
    private func animateStopped() {
        UIView.animateWithDuration(animationDuration) {
            self.startButton.alpha = 1.0
            self.buttonContainer.alpha = 0.0
        }
        
        pauseButton.setTitle("Pause", forState: .Normal)
    }
    
    private func animatePaused() {
        pauseButton.setTitle("Resume", forState: .Normal)
    }
    
    private func animateUnpaused() {
        pauseButton.setTitle("Pause", forState: .Normal)
    }

}

// MARK: - UICollectionViewDataSource
extension TimerViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }

    func collectionView(collectionView: UICollectionView,
            numberOfItemsInSection section: Int) -> Int {
        
        if targetPomodoros - section * rowsPerSection >= rowsPerSection {
            return rowsPerSection
        } else {
            return numberOfRowsInLastSection()
        }
    }
    
    func collectionView(collectionView: UICollectionView,
            cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if rowsPerSection * indexPath.section + indexPath.row < completedPomodoros {
            return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewIdentifiers.filledCell,
                forIndexPath: indexPath)
        } else {
            return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewIdentifiers.emptyCell,
                forIndexPath: indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension TimerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        // Set insets on last row only and skip if section is full
        if section != lastSectionIndex() || numberOfRowsInLastSection() == 0 {
            return UIEdgeInsetsMake(0, 0, 12, 0)
        }
        
        // Cell width + cell spacing
        let cellWidth = 30 + 14
        let inset = (collectionView.frame.width - CGFloat(numberOfRowsInLastSection() * cellWidth)) / 2.0
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}
