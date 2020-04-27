//
//  WorkDayCalculator.swift
//  NSW Work Day Calc
//
//  Created by Raj Patel on 26/04/20.
//  Copyright © 2020 Raj Patel. All rights reserved.
//

import Foundation

class WorkDayCalculator {
    
    enum WeekDays: Int {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
    }

    enum HolidayType {
        case absolute
        case mutable
    }

    struct AdjustedFirstDay {
        var adjustedWeekdays: Int
        var adjustedDate: Date?
    }

    struct AllWeekDays {
        var workDays: Int
        var leftOverDays: Int
    }

    struct EasterHolidays {
        var goodFriday: Date?
        var easterMonday: Date?
    }
    
    private var calendar = Calendar(identifier: .gregorian)
    
    var timezone: TimeZone? {
        didSet {
            calendar.timeZone = timezone ?? TimeZone.current
        }
    }
    
    /// Calculates all work day by taking away all weekends and public holidays from the supplied date range
    /// - Parameters:
    ///   - start: Start date string
    ///   - finish: Finish date string
    ///   - dateFormat: Date format of the supplied string
    /// - Returns: Number of work days
    func calculateWorkDays(with start: String, and finish: String, in dateFormat: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        guard let startDate = dateFormatter.date(from: start),
            let endDate = dateFormatter.date(from: finish) else {
                print("Enter valid dates")
                return nil
        }
        return calculateWorkDays(with: startDate, and: endDate)
    }
    
    /// Calculates all work day by taking away all weekends and public holidays from the supplied date range
    /// - Parameters:
    ///   - start: Start date
    ///   - finish: Finish date
    /// - Returns: Number of work days
    func calculateWorkDays(with start: Date, and finish: Date) -> Int? {
        //Adjusted to not include start and finish dates
        guard let adjustedStart = calendar.date(byAdding: DateComponents(day: 1), to: start),
            let adjustedEnd = calendar.date(byAdding: DateComponents(day: -1), to: finish),
            adjustedStart <= adjustedEnd else {
                print("Enter a valid range")
                return nil
        }
        
        let allWeekDays = numberOfDaysWithoutTheWeekend(from: adjustedStart, to: adjustedEnd)
        let holidays = [easterHolidayCounter(in: adjustedStart, and: adjustedEnd),
                        australiaDay(in: adjustedStart, and: adjustedEnd),
                        christmasDay(in: adjustedStart, and: adjustedEnd),
                        newYearsDay(in: adjustedStart, and: adjustedEnd),
                        boxingDay(in: adjustedStart, and: adjustedEnd),
                        anzacDay(in: adjustedStart, and: adjustedEnd),
                        queensBirthday(in: adjustedStart, and: adjustedEnd),
                        labourDay(in: adjustedStart, and: adjustedEnd)].reduce(0, +)
        return allWeekDays - holidays
    }
    
    /// Calculates the occurrences of Easter Holidays in the date  range. Special case - as it occurs on a different day every year. This count represents Good friday and Easter monday.
    /// - Parameters:
    ///   - start: Start Date
    ///   - end: End date
    /// - Returns: Number of occurrences
    func easterHolidayCounter(in start: Date, and end: Date) -> Int {
        var easterHolidayCount = 0
        let startYear = calendar.component(.year, from: start)
        let endYear = calendar.component(.year, from: end)
        for year in startYear...endYear {
            let easterHoliday = easterHolidays(in: year)
            if let goodFriday = easterHoliday.goodFriday {
                easterHolidayCount = goodFriday >= start && goodFriday <= end ? easterHolidayCount + 1 : easterHolidayCount
            }
            if let easterMonday = easterHoliday.easterMonday {
                easterHolidayCount = easterMonday >= start && easterMonday <= end ? easterHolidayCount + 1 : easterHolidayCount
            }
        }
        return easterHolidayCount
    }
    
    /// Calculates the occurrences of Australia day in the date  range
    /// - Parameters:
    ///   - start: Start Date
    ///   - end: End date
    /// - Returns: Number of occurrences
    func australiaDay(in start: Date, and end: Date) -> Int {
        return holidayCounter(of: .mutable, with: DateComponents(month: 1, day: 26), isBetween: start, and: end)
    }
    
    /// Calculates the occurrences of Christmas day in the date  range
    /// - Parameters:
    ///   - start: Start Date
    ///   - end: End date
    /// - Returns: Number of occurrences
    func christmasDay(in start: Date, and end: Date) -> Int {
        return holidayCounter(of: .mutable, with: DateComponents(month: 12, day: 25), isBetween: start, and: end)
    }
    
    /// Calculates the occurrences of New Year's day in the date  range
    /// - Parameters:
    ///   - start: Start Date
    ///   - end: End date
    /// - Returns: Number of occurrences
    func newYearsDay(in start: Date, and end: Date) -> Int {
        return holidayCounter(of: .mutable, with: DateComponents(month: 1, day: 1), isBetween: start, and: end)
    }
    
    /// Calculates the occurrences of Boxing day in the date  range, boxing day is a special case where observed date always skips 2 days, hence, calculated separately.
    /// - Parameters:
    ///   - start: Start Date
    ///   - end: End date
    /// - Returns: Number of occurrences
    func boxingDay(in start: Date, and end: Date) -> Int {
        var boxingDayCount = 0
        var components = DateComponents(month: 12, day: 26)
        func checkIfBoxingDayInRange(in year: Int) -> Bool {
            components.year = year
            guard let nonNilBoxingDayDate = calendar.date(from: components) else {
                return false
            }
            var boxingDayDate = nonNilBoxingDayDate
            if [WeekDays.saturday.rawValue, WeekDays.sunday.rawValue].contains(calendar.component(.weekday, from: boxingDayDate)),
                let adjustedDate = calendar.date(byAdding: DateComponents(day: 2), to: boxingDayDate) {
                boxingDayDate = adjustedDate
            }
            return boxingDayDate >= start && boxingDayDate <= end
        }
        let startYear = calendar.component(.year, from: start)
        let endYear = calendar.component(.year, from: end)
        for year in startYear...endYear {
            if checkIfBoxingDayInRange(in: year) {
                boxingDayCount += 1
            }
        }
        return boxingDayCount
    }
    
    /// Calculates the occurrences of Anzac day in the date  range
    /// - Parameters:
    ///   - start: Start Date
    ///   - end: End date
    /// - Returns: Number of occurrences
    func anzacDay(in start: Date, and end: Date) -> Int {
        return holidayCounter(of: .absolute, with: DateComponents(month: 4, day: 25), isBetween: start, and: end)
    }
    
    /// Calculates the occurrences of  Queen's birthday in the date  range
    /// - Parameters:
    ///   - start: Start Date
    ///   - end: End date
    /// - Returns: Number of occurrences
    func queensBirthday(in start: Date, and end: Date) -> Int {
        return holidayCounter(of: .absolute, with: DateComponents(month: 6, weekday: 2, weekdayOrdinal: 2), isBetween: start, and: end)
    }
    
    
    /// Calculates the occurrences of labour day in the date  range
    /// - Parameters:
    ///   - start: Start Date
    ///   - end: End date
    /// - Returns: Number of occurrences
    func labourDay(in start: Date, and end: Date) -> Int {
        return holidayCounter(of: .absolute, with: DateComponents(month: 10, weekday: 2, weekdayOrdinal: 1), isBetween: start, and: end)
    }
    
    /// Calculates how many week days we have in the given date range
    /// - Parameters:
    ///   - start: Start date of the range
    ///   - end: End date of the range
    /// - Returns: Number of week days (Int)
    func numberOfDaysWithoutTheWeekend(from start: Date, to end: Date) -> Int {
        var weekDayCount = 0
        let firstMondayAfterStartDay = adjustedFirstDayToMonday(for: start)
        if let dateForMonday = firstMondayAfterStartDay.adjustedDate,  dateForMonday <= end {
            let totalDaysFromFirstMondayInRange = calendar.dateComponents([.day], from: dateForMonday, to: end).day == 0 ? 1 : calendar.dateComponents([.day], from: dateForMonday, to: end).day
            let allWeekDays = numberOfWeekDays(from: totalDaysFromFirstMondayInRange)
            let leftOverFirstDay = calendar.date(byAdding: DateComponents(day: -allWeekDays.leftOverDays), to: end)
            weekDayCount = allWeekDays.workDays +  leftOverWeekDays(days: allWeekDays.leftOverDays, and: leftOverFirstDay, lastDay: end) + firstMondayAfterStartDay.adjustedWeekdays
        } else {
            weekDayCount = leftOverWeekDays(days: calendar.dateComponents([.day], from: start, to: end).day ?? 0, and: start, lastDay: end)
        }
        return weekDayCount
    }
    
    /// Given the left over days (always less than 7) this calculates the week days.
    /// - Parameters:
    ///   - days: Number of days
    ///   - start: Date to calculate week days from
    /// - Returns: Number of days
    private func leftOverWeekDays(days: Int, and start: Date?, lastDay: Date) -> Int {
        var weekDayCount = 0
        
        guard days >= 0, let start = start else {
            return weekDayCount
        }
        var dayRange = days
        if dayRange == 0 {
            dayRange = 1
        }
        
        for day in 0...dayRange {
            if let date = calendar.date(byAdding: DateComponents(day: day), to: start),
                date <= lastDay,
             ![WeekDays.sunday.rawValue, WeekDays.saturday.rawValue].contains(calendar.dateComponents([.weekday], from: date).weekday) {
                weekDayCount += 1
            }
        }
        return weekDayCount
    }
    
    
    /// Given the amount of days, this calculates the numer of week days and the "left over days" (days that spill over in to the following week but dont complete a full week)
    /// - Parameter days: Number of days
    /// - Returns: AllWeekDays - number of week days and left over days
    private func numberOfWeekDays(from days: Int?) -> AllWeekDays {
        guard let days = days else {
            return AllWeekDays(workDays: 0, leftOverDays: 0)
        }
        let numOfDays = (days / 7) * 5
        let leftOverDays = days % 7
        return AllWeekDays(workDays: numOfDays, leftOverDays: leftOverDays)
    }
    
    
    /// Adjusts the date to monday and counts the amount of days it had to adjust. Count only includes week days
    /// - Parameter date: Date to adjust (this dates is always the start date of the range)
    /// - Returns: AdjustedFirstDay - the adjusted date and the amount of days we had to adjust
    private func adjustedFirstDayToMonday(for date: Date) -> AdjustedFirstDay {
        let firstday = calendar.dateComponents([.weekday], from: date)
        guard let weekday = firstday.weekday else {
            return AdjustedFirstDay(adjustedWeekdays: 0, adjustedDate: nil)
        }
        let adjustedFirstDay: AdjustedFirstDay
        switch weekday {
        case WeekDays.sunday.rawValue:
            let adjustedDate = calendar.date(byAdding: .day, value: 1, to: date)
            adjustedFirstDay = AdjustedFirstDay(adjustedWeekdays: 0, adjustedDate: adjustedDate)
        case WeekDays.monday.rawValue:
            adjustedFirstDay = AdjustedFirstDay(adjustedWeekdays: 0, adjustedDate: date) //no need to adjust
        case WeekDays.tuesday.rawValue:
            let adjustedDate = calendar.date(byAdding: .day, value: 6, to: date)
            adjustedFirstDay = AdjustedFirstDay(adjustedWeekdays: 4, adjustedDate: adjustedDate)
        case WeekDays.wednesday.rawValue:
            let adjustedDate = calendar.date(byAdding: .day, value: 5, to: date)
            adjustedFirstDay = AdjustedFirstDay(adjustedWeekdays: 3, adjustedDate: adjustedDate)
        case WeekDays.thursday.rawValue:
            let adjustedDate = calendar.date(byAdding: .day, value: 4, to: date)
            adjustedFirstDay = AdjustedFirstDay(adjustedWeekdays: 2, adjustedDate: adjustedDate)
        case WeekDays.friday.rawValue:
            let adjustedDate = calendar.date(byAdding: .day, value: 3, to: date)
            adjustedFirstDay = AdjustedFirstDay(adjustedWeekdays: 1, adjustedDate: adjustedDate)
        case WeekDays.saturday.rawValue:
            let adjustedDate = calendar.date(byAdding: .day, value: 2, to: date)
            adjustedFirstDay = AdjustedFirstDay(adjustedWeekdays: 0, adjustedDate: adjustedDate)
        default:
            return AdjustedFirstDay(adjustedWeekdays: 0, adjustedDate: nil)
        }
        return adjustedFirstDay
    }
    
    /// Checks if the given holiday falls between the range
    /// - Parameters:
    ///   - type: Holiday type. Absolute type dictates the holiday will not be affected by weekend
    ///   - components: Holiday's date described by components
    ///   - start: Start date of the range
    ///   - end: End date of the range
    /// - Returns: true if the holiday occurs in the range
    func checkIfHoliday(of type: HolidayType, with components: DateComponents, isBetween start: Date,  and end: Date) -> Bool {
        guard let nonNilHolidayDate = calendar.date(from: components) else {
            return false
        }
        var holidayDate = nonNilHolidayDate
        switch type {
        case .mutable:
            if calendar.component(.weekday, from: holidayDate) == WeekDays.saturday.rawValue,
                let adjustedDate = calendar.date(byAdding: DateComponents(day: 2), to: holidayDate) {
                holidayDate = adjustedDate
            } else if calendar.component(.weekday, from: holidayDate) == WeekDays.sunday.rawValue,
                let adjustedDate = calendar.date(byAdding: DateComponents(day: 1), to: holidayDate) {
                holidayDate = adjustedDate
            }
            return holidayDate >= start && holidayDate <= end
        
        case .absolute:
            if ![WeekDays.sunday.rawValue, WeekDays.saturday.rawValue].contains(calendar.component(.weekday, from: holidayDate)) {
                return holidayDate >= start && holidayDate <= end
            } else {
                return false
            }
        }
    }
    
    /// Iterates through the years calculated from the range and incremements the holiday count
    /// - Parameters:
    ///   - type: Holiday type. Absolute type dictates the holiday will not be affected by weekend
    ///   - components: Holiday's date described by components
    ///   - start: Start date of the range
    ///   - end: End date of the range
    /// - Returns: Number of times a  particular holiday occurs in the given range
    func holidayCounter(of type: HolidayType, with components: DateComponents, isBetween start: Date,  and end: Date) -> Int {
        var holidayCount = 0
        let startYear = calendar.component(.year, from: start)
        let endYear = calendar.component(.year, from: end)
        var dateComponents = components
        for year in startYear...endYear {
            dateComponents.year = year
            if checkIfHoliday(of: type, with: dateComponents, isBetween: start, and: end) {
                holidayCount += 1
            }
        }
        return holidayCount
    }
    
    ///Easter Algorithm was taken from: "https://gist.github.com/duedal/2eabcede718c69670102"
    /// Calculates the  date of Good friday and Easter Monday for a given year using Butcher's Algorithm
    /// - Parameter year: inquiry year
    /// - Returns: EasterHolidays - Date of Good friday and Easter Monday
    private func easterHolidays(in year : Int) -> EasterHolidays {
        let a = year % 19
        let b = Int(floor(Double(year) / 100))
        let c = year % 100
        let d = Int(floor(Double(b) / 4))
        let e = b % 4
        let f = Int(floor(Double(b+8) / 25))
        let g = Int(floor(Double(b-f+1) / 3))
        let h = (19*a + b - d - g + 15) % 30
        let i = Int(floor(Double(c) / 4))
        let k = c % 4
        let L = (32 + 2*e + 2*i - h - k) % 7
        let m = Int(floor(Double(a + 11*h + 22*L) / 451))
        var components = DateComponents()
        components.year = year
        components.month = Int(floor(Double(h + L - 7*m + 114) / 31))
        components.day = ((h + L - 7*m + 114) % 31) + 1
        components.timeZone = TimeZone(secondsFromGMT: 0)
        guard let easterSunday = calendar.date(from: components) else {
            return EasterHolidays(goodFriday: nil, easterMonday: nil)
        }
        var easterHolidays = EasterHolidays(goodFriday: nil, easterMonday: nil)
        if let goodFriday = calendar.date(byAdding: DateComponents(day: -2), to: easterSunday) {
            easterHolidays.goodFriday = goodFriday
        }
        if let easterMonday = calendar.date(byAdding: DateComponents(day: 1), to: easterSunday) {
            easterHolidays.easterMonday = easterMonday
        }
        return easterHolidays
    }
}
