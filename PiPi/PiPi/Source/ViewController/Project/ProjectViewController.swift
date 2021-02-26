//
//  ProjectViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/19.
//

import UIKit
import RxSwift
import RxCocoa

class ProjectViewController: UIViewController {
    
    @IBOutlet weak var projectTableView: UITableView!
    
    private let disposeBag = DisposeBag()
    private let viewModel = ProjectViewModel()
    private let loadProject = BehaviorRelay<Void>(value: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    func bindViewModel() {
        let input = ProjectViewModel.input(loadProject: loadProject.asSignal(onErrorJustReturn: ()), selectIndexPath: projectTableView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input)
        
        output.detailProject.emit(onNext: {[unowned self] id in
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "calendarVC") as? CalendarViewController else { return }
            vc.selectIndexPath = Int(id)!
            navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        ProjectViewModel.loadProject.bind(to: projectTableView.rx.items(cellIdentifier: "projectCell", cellType: UITableViewCell.self)) { (index, element, cell) in
            cell.textLabel?.text = element.title
        }.disposed(by: rx.disposeBag)
        projectTableView.layer.cornerRadius = 20
        view.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
        
        projectTableView.rowHeight = 74
    }
}
