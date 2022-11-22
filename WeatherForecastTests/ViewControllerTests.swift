//
//  WeatherForecastTests.swift
//  WeatherForecastTests
//
//  Created by expert on 17/09/22.
//

import XCTest
@testable import WeatherForecast
import CoreData
class ViewControllerTests: XCTestCase {

    var vc: ViewController?
    override func setUpWithError() throws {
       vc = ViewController()
    }

    override func tearDownWithError() throws {
        vc = nil
    }

    func testViewDidLoad() throws {
        vc?.viewDidLoad()
        XCTAssertEqual(vc?.tableView.estimatedRowHeight, 50)
        XCTAssertEqual(vc?.tableView.estimatedSectionHeaderHeight, 50)
        XCTAssertEqual(vc?.tableView.sectionHeaderHeight, UITableView.automaticDimension)
        XCTAssertEqual(vc?.tableView.rowHeight, UITableView.automaticDimension)
        XCTAssertEqual(vc?.tableView.separatorStyle, UITableViewCell.SeparatorStyle.none)
        
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "ResponseData")
        
        //3
        let expectation = self.expectation(description: "Wait for getting data from CoreData")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                if let responseData = try managedContext.fetch(fetchRequest).first?.value(forKey: "data") as? String {
                    XCTAssertNotNil(self.vc?.publisher?.value)
                    expectation.fulfill()
                } else {
                    XCTAssertNil(self.vc?.publisher?.value)
                    expectation.fulfill()
                }
                
            } catch {}
        }
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testNoOfSection() {
        XCTAssertEqual(vc?.numberOfSections(in: vc?.tableView ?? UITableView()), 2)
    }
    
    func testNoOfRows() {
        XCTAssertEqual(vc?.tableView(vc?.tableView ?? UITableView(), numberOfRowsInSection: 0), 1)
    }
    
    func testViewForHeaderInSection() {
        XCTAssertNotNil(vc?.tableView(vc?.tableView ?? UITableView(), viewForHeaderInSection: 0))
        if let label = vc?.tableView(vc?.tableView ?? UITableView(), viewForHeaderInSection: 0) as? UILabel {
            XCTAssertEqual(label.text, "Weather foreCast")
        }
        XCTAssertNil(vc?.tableView(vc?.tableView ?? UITableView(), viewForHeaderInSection: 1))
    }
    
    func testCellForRow() {
        if let cell = vc?.tableView(vc?.tableView ?? UITableView(), viewForHeaderInSection: 0) as? CurrentDetailsTableViewCell {
            XCTAssertEqual(cell.reuseIdentifier, "currentDetailsCell")
        }
        if let cell = vc?.tableView(vc?.tableView ?? UITableView(), viewForHeaderInSection: 1) as? ForeCastDetailsTableViewCell {
            XCTAssertEqual(cell.reuseIdentifier, "weatherForecastBlockCell")
        }
    }
}
