//
//  TypeConverter.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 2/10/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import Foundation

class TypeConverter {
    
    let dateformatter = DateFormatter()
    let weekDayDateFormatter = DateFormatter()
    
    init() {
        
        dateformatter.dateFormat = "dd/MM/yyyy HH:mm"
        weekDayDateFormatter.dateFormat = "dd/MM/yyyy EEE"
    }
    
    func dateToString(date: Date) -> String {
        
        return dateformatter.string(from:date)
        
    }
    
    func stringToDate(str: String) -> Date {
        
        return dateformatter.date(from: str)!
        
    }
    
    func dateToStringIncludingWeekday(date: Date) -> String {
        
        return weekDayDateFormatter.string(from:date)
    }
    
    func stringToDateIncludingWeekday(str: String) -> Date {
        return weekDayDateFormatter.date(from: str)!
    }
    
}
