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
        self.navigationController?.isNavigationBarHidden = true

        projectTableView.layer.cornerRadius = 20
        view.backgroundColor = UIColor().hexUIColor(hex: "61BFAD")
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func bindViewModel() {
        let input = ProjectViewModel.input(loadProject: loadProject.asSignal(onErrorJustReturn: ()), selectIndexPath: projectTableView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input)
        
        output.detailProject.emit(onNext: { id in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "calendarVC") as? CalendarViewController else { return }
            vc.selectIndexPath = Int(id)!
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        ProjectViewModel.loadProject.bind(to: projectTableView.rx.items(cellIdentifier: "projectCell", cellType: UITableViewCell.self)) { (index, element, cell) in
            cell.textLabel?.text = element.title
        }.disposed(by: rx.disposeBag)
        
        projectTableView.rowHeight = 74
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
