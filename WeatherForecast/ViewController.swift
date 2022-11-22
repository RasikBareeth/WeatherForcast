//
//  ViewController.swift
//  WeatherForecast
//
//  Created by expert on 17/09/22.
//

import UIKit
import Combine
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let city = "Chennai"
    var currentLocationData: Location?
    var foreCastData: Forecast?
    var publisher: CurrentValueSubject<(currentLocationData: Location?, foreCastData: Forecast?)?, Never>?
    var store = Set<AnyCancellable>()
    let tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        table.register(CurrentDetailsTableViewCell.self, forCellReuseIdentifier: CurrentDetailsTableViewCell.cellIdentifier)
        table.register(ForeCastDetailsTableViewCell.self, forCellReuseIdentifier: ForeCastDetailsTableViewCell.cellIdentifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        configureTableView()
        WeatherForecastModel.shared.checkFordataInPersistance(city, self)
    }
    
    func reloadViewsWithPublisher() {
        publisher?.sink(receiveValue: { model in
            self.currentLocationData = model?.currentLocationData
            self.foreCastData = model?.foreCastData
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }).store(in: &store)
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 50
        tableView.estimatedSectionHeaderHeight = 50
        tableView.sectionHeaderHeight =  UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
    }
    
    func callApiError() {
        let alert = UIAlertController(title: "Alert", message: "API Error", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let titleLabel = UILabel()
            titleLabel.text = "Weather foreCast"
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: .none)
            return titleLabel
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCell(indexPath)
    }
    
    func getCell(_ indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = self.tableView.dequeueReusableCell(withIdentifier: CurrentDetailsTableViewCell.cellIdentifier, for: indexPath) as? CurrentDetailsTableViewCell {
                cell.configure(currentLocationData)
                return cell
            }
            return UITableViewCell()
        case 1:
            if let cell = self.tableView.dequeueReusableCell(withIdentifier: ForeCastDetailsTableViewCell.cellIdentifier, for: indexPath) as? ForeCastDetailsTableViewCell {
                cell.configure(foreCastData)
                return cell
            }
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: "https:\(link)") else { return }
        downloaded(from: url, contentMode: mode)
    }
}
