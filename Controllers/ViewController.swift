//
//  ViewController.swift
//  
//
//  Created by Shubham Arya on 4/6/22.
//

import UIKit

class ViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupTableview()
    }
    
    func setupNavbar() {
        self.title = "AudioVison"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(helpTapped))
    }
    
    @objc func helpTapped() {
        
    }

}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func setupTableview(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(HomeCategoryTableCell.self, forCellReuseIdentifier: HomeCategoryTableCell.idenitifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeCategoryTableCell.idenitifier, for: indexPath) as? HomeCategoryTableCell else {return UITableViewCell()}
        cell.configure(for: indexPath)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
    
    
}
