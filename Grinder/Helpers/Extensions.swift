//
//  Extensions.swift
//  Grinder
//
//  Created by Beavean on 22.09.2022.
//

import UIKit

extension Date {
    
    func getStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func getUniqueStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyyHHmmss"
        return dateFormatter.string(from: self)
    }

    func interval(ofComponent component: Calendar.Component, fromDate date: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let startDate = currentCalendar.ordinality(of: component, in: .era, for: date) else { return 0 }
        guard let endDate = currentCalendar.ordinality(of: component, in: .era, for: self) else { return 0 }
        return endDate - startDate
    }
}

extension UIColor {
    
    func primary() -> UIColor {
        return UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    }
    
    func tabBarUnselected() -> UIColor {
        return UIColor(red: 255/255, green: 216/255, blue: 223/255, alpha: 1)
    }
}
