//
//  FiltersViewController.swift
//  News
//
//  Created by Danylo Krysevych on 09.06.2022.
//

import UIKit

class FiltersViewController: UIViewController {

    let countries = ["ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co", "cu", "cz", "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie", "il", "in", "it", "jp", "kr", "lt", "lv", "ma", "mx", "my", "ng", "nl", "no", "nz", "ph", "pl", "pt", "ro", "rs", "ru", "sa", "se", "sg", "si", "sk", "th", "tr", "tw", "ua", "us", "ve", "za"]
    let categories = ["business", "entertainment", "general", "health", "science", "sports", "technology"]
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    var country: String? {
        get {
            UserDefaults.standard.string(forKey: "country")
        } set {
            UserDefaults.standard.set(newValue, forKey: "country")
        }
    }
    
    var category: String? {
        get {
            UserDefaults.standard.string(forKey: "category")
        } set {
            UserDefaults.standard.set(newValue, forKey: "category")
        }
    }
    
    var sources: String? {
        get {
            UserDefaults.standard.string(forKey: "sources")
        } set {
            UserDefaults.standard.set(newValue?.lowercased(), forKey: "sources")
        }
    }
    
    @IBOutlet weak var container: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(segment)
        segment.removeAllSegments()
        for par in 0..<3 {
            segment.insertSegment(withTitle: ParameterType.allCases[par].rawValue, at: par, animated: true)
        }
        build()
    }
    

    @IBAction func choose(_ sender: Any) {
        container.subviews.forEach { $0.removeFromSuperview() }
        build()
    }
    
    
    func build() {
        switch segment.selectedSegmentIndex {
        case 0:
            let picker = UIPickerView()
            container.addSubview(picker)
            picker.translatesAutoresizingMaskIntoConstraints = false
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            picker.topAnchor.constraint(equalTo: picker.superview!.topAnchor, constant: 10).isActive = true
            picker.dataSource = self
            picker.delegate = self
            
            category = nil
            sources = nil
        case 1:
            let textField = UITextField()
            textField.placeholder = "bbc, reuters..."
            container.addSubview(textField)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            textField.topAnchor.constraint(equalTo: textField.superview!.topAnchor, constant: 10).isActive = true
            
            textField.delegate = self
            category = nil
            country = nil
        case 2:
            let picker = UIPickerView()
            container.addSubview(picker)
            picker.translatesAutoresizingMaskIntoConstraints = false
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            picker.topAnchor.constraint(equalTo: picker.superview!.topAnchor, constant: 10).isActive = true
            picker.dataSource = self
            picker.delegate = self
            sources = nil
            country = nil
        default:
            break
        }
    }
    
    

}

extension FiltersViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if segment.selectedSegmentIndex == 2 {
            return categories.count
        }
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if segment.selectedSegmentIndex == 2 {
            category = categories[row]
            return
        }
        country = countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if segment.selectedSegmentIndex == 2 {
            return categories[row]
        }
        return countries[row]
    }
}


extension FiltersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sources = textField.text
        view.endEditing(true)
        return true
    }
}


enum ParameterType: String, CaseIterable {
    case coutry, sources, categories
}
