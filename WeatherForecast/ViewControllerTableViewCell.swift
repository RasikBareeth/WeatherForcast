//
//  ViewControllerTableViewCell.swift
//  WeatherForecast
//
//  Created by expert on 14/10/22.
//

import Foundation
import UIKit

class CurrentDetailsTableViewCell: UITableViewCell {
    static let cellIdentifier = "currentDetailsCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ currentLocationDetails: Location?) {
        self.contentView.subviews.forEach{ $0.removeFromSuperview() }
        let countryLabel = UILabel()
        countryLabel.text = "Country: "
        
        let cityLabel = UILabel()
        cityLabel.text = "City: "
        
        let dateLabel = UILabel()
        dateLabel.text = "Date: "
        
        let timeLabel = UILabel()
        timeLabel.text = "Time: "
       
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fill
        verticalStackView.addArrangedSubview(countryLabel)
        verticalStackView.addArrangedSubview(cityLabel)
        verticalStackView.addArrangedSubview(dateLabel)
        verticalStackView.addArrangedSubview(timeLabel)
        if currentLocationDetails == nil {
            verticalStackView.isHidden = true
        }
        let countryLabelValue = UILabel()
        countryLabelValue.text = currentLocationDetails?.country ?? ""
        
        let cityLabelValue = UILabel()
        cityLabelValue.text = currentLocationDetails?.name ?? ""
        
        let dateLabelValue = UILabel()
        dateLabelValue.text = String((currentLocationDetails?.localtime ?? "").prefix(10))
        
        let timeLabelValue = UILabel()
        timeLabelValue.text = String((currentLocationDetails?.localtime ??  "").suffix(5))
        
        let verticalStackViewValue = UIStackView()
        verticalStackViewValue.axis = .vertical
        verticalStackViewValue.distribution = .fillEqually
        verticalStackViewValue.addArrangedSubview(countryLabelValue)
        verticalStackViewValue.addArrangedSubview(cityLabelValue)
        verticalStackViewValue.addArrangedSubview(dateLabelValue)
        verticalStackViewValue.addArrangedSubview(timeLabelValue)
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fill
        horizontalStackView.spacing = 30
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.addArrangedSubview(verticalStackView)
        horizontalStackView.addArrangedSubview(verticalStackViewValue)
        self.contentView.addSubview(horizontalStackView)
        NSLayoutConstraint.activate([
            horizontalStackView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 30),
            horizontalStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),
        ])
    }
}

class WeatherForecastBlockCell: UICollectionViewCell {
    
    static let identifier = "weatherForecastBlockCell"
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func configure(_ foreCastData: Forecast?, _ indexPath: IndexPath) {
        guard let forecastday = foreCastData?.forecastday else {
            return
        }
        let verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fill
        verticalStackView.spacing = 8
        let icon = UIImageView()
        icon.downloaded(from: forecastday[indexPath.item].day.condition.icon)
        let minTemp = UILabel()
        minTemp.text = "min Temp: \(String(forecastday[indexPath.item].day.mintempC))°C"
        let maxTemp = UILabel()
        maxTemp.text = "max Temp: \(String(forecastday[indexPath.item].day.maxtempC))°C"
        let date = UILabel()
        date.text = "Date: \(forecastday[indexPath.item].date)"
        verticalStackView.addArrangedSubview(icon)
        verticalStackView.addArrangedSubview(minTemp)
        verticalStackView.addArrangedSubview(maxTemp)
        verticalStackView.addArrangedSubview(date)
        self.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
class ForeCastDetailsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    static let cellIdentifier = "foreCastDetailsCell"
    var foreCastData: Forecast?
    let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ forecastData: Forecast?) {
        let collectionView = UICollectionView(frame: CGRect(x: 20, y: 20, width: 100, height: 200), collectionViewLayout: layout)
        foreCastData = forecastData
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(WeatherForecastBlockCell.self, forCellWithReuseIdentifier: WeatherForecastBlockCell.identifier)
        self.contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
            
        ])
        self.layoutIfNeeded()
        collectionView.heightAnchor.constraint(equalToConstant: collectionView.collectionViewLayout.collectionViewContentSize.height).isActive = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foreCastData?.forecastday.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherForecastBlockCell.identifier, for: indexPath) as? WeatherForecastBlockCell {
            cell.configure(foreCastData, indexPath)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 160, height: 160)
    }
}
