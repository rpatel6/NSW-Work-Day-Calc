//
//  NSW_Work_Day_CalcTests.swift
//  NSW Work Day CalcTests
//
//  Created by Raj Patel on 26/04/20.
//  Copyright © 2020 Raj Patel. All rights reserved.
//

import XCTest
@testable import NSW_Work_Day_Calc

class NSW_Work_Day_CalcTests: XCTestCase {
    
    ///This class only shows the testability of the WorkDayCalculator, hence, only a small subset of tests are written

    var calculator: WorkDayCalculator?
    
    override func setUpWithError() throws {
        calculator = WorkDayCalculator()
    }
    
    func testDateCalculatorWithStringInputShortRange() throws {
        let days = calculator?.calculateWorkDays(with: "7/8/2014", and: "11/8/2014", in: "dd/MM/yyyy")
        XCTAssertTrue(days == 1, "There should be 1 working day in this interval not \(days ?? 0)")
    }
    
    func testDateCalculatorWithStringInputLongRange() throws {
        let days = calculator?.calculateWorkDays(with: "1/3/2022", and: "20/4/2025", in: "dd/MM/yyyy")
        XCTAssertTrue(days == 790, "There should be 790 working day in this interval not \(days ?? 0)")
    }
    
    func testDateCalculatorWithDateInputShortRange() throws {
        let calendar = Calendar(identifier: .gregorian)
        var startComponents = DateComponents()
        startComponents.year = 2014
        startComponents.day = 14
        startComponents.month = 8
        
        var endComponents = DateComponents()
        endComponents.year = 2014
        endComponents.day = 24
        endComponents.month = 8
        guard let startDate = calendar.date(from: startComponents),
            let endDate = calendar.date(from: endComponents) else {
                return
        }
        let days = calculator?.calculateWorkDays(with: startDate, and: endDate)
        XCTAssertTrue(days == 6, "There should be 6 working day in this interval not \(days ?? 0)")
    }

    func testDateCalculatorWithDateInputLongRange() throws {
        let calendar = Calendar(identifier: .gregorian)
        var startComponents = DateComponents()
        startComponents.year = 2019
        startComponents.day = 5
        startComponents.month = 3
        
        var endComponents = DateComponents()
        endComponents.year = 2023
        endComponents.day = 27
        endComponents.month = 12
        guard let startDate = calendar.date(from: startComponents),
            let endDate = calendar.date(from: endComponents) else {
                return
        }
        let days = calculator?.calculateWorkDays(with: startDate, and: endDate)
        XCTAssertTrue(days == 1214, "There should be 1214 working day in this interval not \(days ?? 0)")
    }
    
    func testWeekDayCalculationLongRange() throws {
        let calendar = Calendar(identifier: .gregorian)
        var startComponents = DateComponents()
        startComponents.year = 2019
        startComponents.day = 6
        startComponents.month = 3
        
        var endComponents = DateComponents()
        endComponents.year = 2023
        endComponents.day = 26
        endComponents.month = 12
        guard let startDate = calendar.date(from: startComponents),
            let endDate = calendar.date(from: endComponents) else {
                return
        }
        let days = calculator?.numberOfDaysWithoutTheWeekend(from: startDate, to: endDate)
        XCTAssertTrue(days == 1255, "There should be 1255 working day in this interval not \(days ?? 0)")
    }
    
    func testWeekDayCalculationShortRange() throws {
        let calendar = Calendar(identifier: .gregorian)
        var startComponents = DateComponents()
        startComponents.year = 2020
        startComponents.day = 6
        startComponents.month = 5
        
        var endComponents = DateComponents()
        endComponents.year = 2020
        endComponents.day = 13
        endComponents.month = 5
        guard let startDate = calendar.date(from: startComponents),
            let endDate = calendar.date(from: endComponents) else {
                return
        }
        let days = calculator?.numberOfDaysWithoutTheWeekend(from: startDate, to: endDate)
        XCTAssertTrue(days == 6, "There should be 6 working day in this interval not \(days ?? 0)")
    }
    
    func testDateCalculatorWithHolidayCounting() throws {
        let calendar = Calendar(identifier: .gregorian)
        var startComponents = DateComponents()
        startComponents.year = 2019
        startComponents.day = 5
        startComponents.month = 3
        
        var endComponents = DateComponents()
        endComponents.year = 2023
        endComponents.day = 27
        endComponents.month = 12
        guard let adjustedStart = calendar.date(from: startComponents),
            let adjustedEnd = calendar.date(from: endComponents) else {
                return
        }
        let holidays = [calculator?.easterHolidayCounter(in: adjustedStart, and: adjustedEnd),
                        calculator?.australiaDay(in: adjustedStart, and: adjustedEnd),
                        calculator?.christmasDay(in: adjustedStart, and: adjustedEnd),
                        calculator?.newYearsDay(in: adjustedStart, and: adjustedEnd),
                        calculator?.boxingDay(in: adjustedStart, and: adjustedEnd),
                        calculator?.anzacDay(in: adjustedStart, and: adjustedEnd),
                        calculator?.queensBirthday(in: adjustedStart, and: adjustedEnd),
                        calculator?.labourDay(in: adjustedStart, and: adjustedEnd)].compactMap{$0}.reduce(0, +)
        XCTAssertTrue(holidays == 41, "There should be 41 public holidays in this interval not \(holidays)")
    }

}
