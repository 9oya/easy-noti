//
//  NotiDetailNotiDetailViewController.swift
//  easy-noti
//
//  Created by 9oya on 01/08/2020.
//  Copyright © 2020 Dymm. All rights reserved.
//

import UIKit
import ColorCompatibility
import RxSwift
import RxCocoa

class NotiDetailViewController: UIViewController, NotiDetailViewInput {
    // MARK: Properties
    var notiDetailTableView: UITableView!
    var saveButton: UIButton!
    
    var output: NotiDetailViewOutput!
    var configurator = NotiDetailModuleConfigurator()
    var disposeBag = DisposeBag()
    
    // MARK: Life cycle
    override func loadView() {
        super.loadView()
        output.viewIsReady()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    // MARK: NotiDetailViewInput
    var notiDetailViewModel = NotiDetailViewModel()
    
    func setupInitialState() {
        setupLayout()
    }
    
    func setupData(data: NotiGroupMO?) {
        configurator.configureModuleForViewInput(viewInput: self)
        output.setupData {
            return data
        }
    }
    
    func reloadTableView() {
        notiDetailTableView.reloadData()
    }
}

extension NotiDetailViewController {
    private func bind() {
        notiDetailViewModel.contentInputText
            .subscribe(onNext: { (content) in
                self.output.setupContent {
                    return content
                }
            }).disposed(by: disposeBag)
        
        saveButton.rx.tap
            .do(onNext: {
                self.view.showSpinner()
                self.output.createNotification(
                    title: self.notiDetailViewModel.title,
                    content: self.notiDetailViewModel.content,
                    hour: self.notiDetailViewModel.hour,
                    minute: self.notiDetailViewModel.minute,
                    daysOfWeekDict: self.notiDetailViewModel.daysOfWeekDict,
                    isOn: self.notiDetailViewModel.isOn
                )
            })
            .subscribe(onNext: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.view.hideSpinner()
                    self.output.backToWhereCameFrom(from: self)
                }
            }).disposed(by: disposeBag)
    }
}

extension NotiDetailViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return output.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: notiDetailTableFooterId) as! NotiDetailTableFooter
        output.configureNotiDetailTableFooter(view: view)
        view.switchChangedAction = { isOn in
            self.notiDetailViewModel.isOnInput.onNext(isOn)
        }
        view.deleteButtonTappedAction = {
            // TODO
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: notiDetailTalbeCellId, for: indexPath) as! NotiDetailTableCell
        output.configureNotiDetailTableCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            // TODO
            print()
        case 1:
            output.pushToNotiBodyViewController(from: self)
        case 2:
            // TODO
            print()
        case 3:
            // TODO
            print()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return view.frame.height / 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 8
    }
}

extension NotiDetailViewController {
    private func setupLayout() {
        // MARK: Setup super-view
        view.backgroundColor = ColorCompatibility.systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Add Notification"
        
        // MARK: Setup sub-view properties
        notiDetailTableView = {
            let tableView = UITableView(frame: .zero, style: .grouped)
            tableView.separatorStyle = .none
            tableView.backgroundColor = ColorCompatibility.systemBackground
            tableView.register(NotiDetailTableFooter.self, forHeaderFooterViewReuseIdentifier: notiDetailTableFooterId)
            tableView.register(NotiDetailTableCell.self, forCellReuseIdentifier: notiDetailTalbeCellId)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            return tableView
        }()
        saveButton = {
            let button = UIButton()
            button.setTitle("Save", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            button.setTitleColor(.systemTeal, for: .normal)
            return button
        }()
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: saveButton)]
        
        // MARK: Setup UI Hierarchy
        view.addSubview(notiDetailTableView)
        
        // MARK: Dependency injection
        notiDetailTableView.dataSource = self
        notiDetailTableView.delegate = self
        
        // MARK: Setup constraints
        notiDetailTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        notiDetailTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        notiDetailTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        notiDetailTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
}
