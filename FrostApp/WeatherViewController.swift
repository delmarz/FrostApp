//
//  WeatherViewController.swift
//  FrostApp
//
//  Created by Israel Mayor on 5/30/20.
//  Copyright © 2020 Istrael Mayor. All rights reserved.
//

import UIKit
import Spring

class WeatherViewController: UIViewController, FloatingViewControllerDelegate {
	
	enum CardState {
		case expanded
		case collapsed
	 }

	@IBOutlet var weatherTypeImageView: DesignableImageView!
	@IBOutlet var temperatureLabel: DesignableLabel!
	@IBOutlet var windLabel: DesignableLabel!
	@IBOutlet var windHAGLabel: DesignableLabel!
	@IBOutlet var tempHAGLabel: DesignableLabel!
	@IBOutlet var timeLabel: DesignableLabel!
	@IBOutlet var weatherTypeLabel: DesignableLabel!
	@IBOutlet var dateLabel: DesignableLabel!
	@IBOutlet var weatherBgImageView: DesignableImageView!
	
	var stationDetail: StationsDetail?
	var observationDetail: ObservationsResponse?
	var floatingViewController:FloatingViewController!

	let cardHeight:CGFloat = 700
	let cardHandleAreaHeight:CGFloat = 410
	var cardVisible = false
	var initialIndex = 0
	var nextState:CardState {
		return cardVisible ? .collapsed : .expanded
	}
	
	var runningAnimations = [UIViewPropertyAnimator]()
	var animationProgressWhenInterrupted:CGFloat = 0
	var isExpanded = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCard()
				updateData(at: initialIndex)
    }
	
	// MARK: - IBAction
	@IBAction func closeBtnPressed(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: - FloatingViewControllerDelegate
	
	func selectedDateItem(at index: Int) {
		updateData(at: index)
		if isExpanded {
			animateTransitionIfNeeded(state: .collapsed, duration: 0.9)
		}
		animateLabel()
	}
		

	func observerDatePickerBehaviorAnimation(listOfObservations: ObservationsResponse) {
		if isExpanded {
			animateTransitionIfNeeded(state: .collapsed, duration: 0.9)
		}
		self.observationDetail = listOfObservations
		updateData(at: 0)
		
	}
	
	// MARK: Helper Methods
	
	fileprivate func updateData(at index: Int) {
		guard let od = observationDetail else { return }
		guard let ss = stationDetail else {  return }
		floatingViewController.municipalityLabel.text = ss.shortName
		floatingViewController.locationNameLabel.text = ss.municipality
		floatingViewController.countryLabel.text = ss.country
		floatingViewController.stationId = ss.id ?? ""
		
		floatingViewController.delegate = self
		let latLon = ss.geometry?.coordinates?.map { String($0) }
		let latLonString = latLon?.joined(separator: ", ")
		floatingViewController.longAndLatLAbel.text = latLonString
		
		displayDynamicWeatherType(dateString: od.data[index].referenceTime ?? "")
		displayDynamicDataOnWeather(od: od, index: index)
	}
	
	fileprivate func displayDynamicWeatherType(dateString :String) {
		let selectedDate = dateFromString(date: dateString, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
		if checkTime(now: selectedDate, from: 6, toTimeHour: 17) {
			weatherBgImageView.image = UIImage(named: "Sun")
		} else if checkTime(now: selectedDate, from: 17, toTimeHour: 21)  {
			weatherBgImageView.image = UIImage(named: "Blood")
		} else {
			weatherBgImageView.image = UIImage(named: "Moon")
		}
		weatherTypeImageView.animation = "fadeIn"
		weatherTypeImageView.duration = 1.3
		weatherTypeImageView.animate()
	}
	
	fileprivate func displayDynamicDataOnWeather(od: ObservationsResponse, index: Int) {
		dateLabel.text =	String.getStringDateFormat(date: od.data[index].referenceTime ?? "")
		timeLabel.text = String.getStringTimeFormat(date: od.data[index].referenceTime ?? "")
		
		
		if 	let airTempIndex =  od.data[index].observations?.firstIndex(where: { ($0.elementId == "air_temperature")}) {
			let tempLabel = od.data[index].observations?[airTempIndex].value?.string
			let hagTemp = od.data[index].observations?[airTempIndex].level?.value?.string
			tempHAGLabel.text = "\(hagTemp ?? "0") m"
			temperatureLabel.text =  "\(tempLabel ?? "0") ℃"
		}
		if 	let windIndex =  od.data[index].observations?.firstIndex(where: { ($0.elementId == "wind_speed")}) {
			let wind = od.data[index].observations?[windIndex].value?.string
			let hagWind = od.data[index].observations?[windIndex].level?.value?.string
			windHAGLabel.text = "\(hagWind ?? "0") m"
			windLabel.text =  "\(wind ?? "0") m/s"
		}
		
		
		if 	let weatherIndex =  od.data[index].observations?.firstIndex(where: { ($0.elementId == "boolean_fair_weather(cloud_area_fraction P1D)")}) {
			if od.data[index].observations?[weatherIndex].value == 0 {
				weatherTypeImageView.image = UIImage(named: "cloudWhite")
				weatherTypeLabel.text = "Cloudy"
			} else {
				weatherTypeImageView.image = UIImage(named: "sunWhite")
				weatherTypeLabel.text = "Sunny"
			}
		}
	}
	
	
	
	fileprivate func checkTime(now: Date, from timeHour: Int, toTimeHour: Int)->Bool{
			var timeExist:Bool
			let calendar = Calendar.current
			let startTimeComponent = DateComponents(calendar: calendar, hour:timeHour)
			let endTimeComponent   = DateComponents(calendar: calendar, hour: toTimeHour, minute: 00)

			let startOfToday = calendar.startOfDay(for: now)
			let startTime    = calendar.date(byAdding: startTimeComponent, to: startOfToday)!
			let endTime      = calendar.date(byAdding: endTimeComponent, to: startOfToday)!

			if startTime <= now && now <= endTime {
					timeExist = true
			} else {
					timeExist = false
			}
			return timeExist
	}
	
	fileprivate func animateLabel() {
		animateLabel(label: timeLabel, animationText: "fadeInRight")
		animateLabel(label: windLabel, animationText: "zoomIn")
		animateLabel(label: windHAGLabel, animationText: "zoomIn")
		animateLabel(label: temperatureLabel, animationText: "zoomIn")
		animateLabel(label: tempHAGLabel, animationText: "zoomIn")
	}
	
	fileprivate func animateLabel(label: DesignableLabel, animationText: String) {
			label.animation = animationText
			label.duration = 1.4
			label.animate()
	}
	
	// MARK: Handle Gesture
    
    fileprivate func setupCard() {
        floatingViewController = FloatingViewController(nibName:"FloatingViewController", bundle:nil)
				floatingViewController.observationDetail = observationDetail?.data
        self.addChild(floatingViewController)
        self.view.addSubview(floatingViewController.view)
			
			floatingViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        floatingViewController.view.clipsToBounds = true
			
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WeatherViewController.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(WeatherViewController.handleCardPan(recognizer:)))
        floatingViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        floatingViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }

    @objc
    func handleCardTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.floatingViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
	
	// MARK: Handle Animation
    
    fileprivate func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
									self.isExpanded = true
                    self.floatingViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
									self.isExpanded = false
                    self.floatingViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
        }
    }
    
   fileprivate func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
  fileprivate  func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
   fileprivate func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}

