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
        
        print("in")
        rightButton.rx.tap.subscribe(onNext: { _ in
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "addPortfolio") as! AddPortFolioViewController
            let navController = UINavigationController(rootViewController: VC1)
            self.present(navController, animated:true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        
        self.navigationController?.navigationBar.topItem?.title = "Select Portfolio"
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem = leftButton
        
        bindViewModel()
        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            cell.giturlLabel.text = item.giturl
            cell.projectNameLabel.text = item.title
            cell.moreLabel.text = item.introduce
        }.disposed(by: rx.disposeBag)
        
        portfolioTableView.rx.itemSelected.subscribe(onNext: { indexPath in
            if self.countCheck == 0 {
                self.firstPortfolio.accept(indexPath.row)
            }
            if self.countCheck == 1 {
                self.secondPortfolio.accept(indexPath.row)
                self.portfolioTableView.allowsSelection = false
                self.portfolioTableView.allowsSelectionDuringEditing = false
            }
            self.countCheck += 1
            self.portfolioTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }).disposed(by: rx.disposeBag)
        
        output.result.emit(onCompleted: {
            self.loadPortfolio.accept(())
            self.portfolioTableView.reloadData()
        }).disposed(by: rx.disposeBag)
        output.doneResult.emit(onCompleted: { self.dismiss(animated: true, completion: nil)}).disposed(by: self.rx.disposeBag)
    }
    
    func registerCell() {
        let nib = UINib(nibName: "PortfolioTableViewCell", bundle: nil)
        portfolioTableView.register(nib, forCellReuseIdentifier: "portfolioCell")
        portfolioTableView.rowHeight = 140
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//    }

}
