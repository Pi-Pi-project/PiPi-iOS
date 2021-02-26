//
//  PorfolioViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/15.
//

import UIKit
import RxSwift
import RxCocoa

class PorfolioViewController: UIViewController {

    @IBOutlet weak var portfolioTableView: UITableView!
    
    private let loadPortfolio = BehaviorRelay<Void>(value: ())
    private let viewModel = PortfolioViewModel()
    private let firstPortfolio = BehaviorRelay<Int?>(value: nil)
    private let secondPortfolio = BehaviorRelay<Int?>(value: nil)
    private let showEmail = BehaviorRelay<Void>(value: ())
    private var countCheck: Int = 0
    
    lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Add", style: .plain, target: self, action: nil)
    return button
    }()
    
    lazy var leftButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: nil)
    return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "Select Portfolio"
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton
        
        rightButton.rx.tap.subscribe(onNext: {[unowned self] _ in
            let VC1 = storyboard!.instantiateViewController(withIdentifier: "addPortfolio") as! AddPortFolioViewController
            let navController = UINavigationController(rootViewController: VC1)
            self.present(navController, animated:true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        bindViewModel()
        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadPortfolio.accept(())
        portfolioTableView.reloadData()
    }
    
    func bindViewModel() {
        let input = PortfolioViewModel.input(
            showEmail: showEmail.asSignal(onErrorJustReturn: ()),
            loadPortfolio: loadPortfolio.asDriver(onErrorJustReturn: ()),
            firstPortfolio: firstPortfolio.asDriver(onErrorJustReturn: nil),
            secondPortfolio: secondPortfolio.asDriver(onErrorJustReturn: nil),
            doneTap: leftButton.rx.tap.asDriver(),
            addTap: rightButton.rx.tap.asDriver())
        let output = viewModel.transform(input)
        
        PortfolioViewModel.loadPortfolio.bind(to: portfolioTableView.rx.items(cellIdentifier: "portfolioCell", cellType: PortfolioTableViewCell.self)) { (row, item, cell) in
            cell.configCell(item)
        }.disposed(by: rx.disposeBag)
        
        portfolioTableView.rx.itemSelected.subscribe(onNext: {[unowned self] indexPath in
            if countCheck == 0 {
                firstPortfolio.accept(indexPath.row)
            }
            if countCheck == 1 {
                secondPortfolio.accept(indexPath.row)
                portfolioTableView.allowsSelection = false
                portfolioTableView.allowsSelectionDuringEditing = false
            }
            countCheck += 1
            portfolioTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onCompleted: {[unowned self] in
            loadPortfolio.accept(())
            portfolioTableView.reloadData()
        }).disposed(by: rx.disposeBag)
        output.doneResult.emit(onCompleted: {[unowned self] in dismiss(animated: true, completion: nil) }).disposed(by: self.rx.disposeBag)
    }
    
    func registerCell() {
        let nib = UINib(nibName: "PortfolioTableViewCell", bundle: nil)
        portfolioTableView.register(nib, forCellReuseIdentifier: "portfolioCell")
        portfolioTableView.rowHeight = 140
    }
}
