//
//  CalendarViewController.swift
//  PiPi
//
//  Created by 이가영 on 2020/11/19.
//

import UIKit
import FSCalendar
import RxCocoa
import RxSwift

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var todoView: UIView!
    @IBOutlet weak var todoTableView: UITableView!
    
    var selectIndexPath = Int()
    private let viewModel = CalendarViewModel()
    private var todoDate = BehaviorRelay<String>(value: "")
    private var alertDone = BehaviorRelay<Void>(value: ())
    private var todoText = BehaviorRelay<String>(value: "")
    
    lazy var addBtn: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Add", style: .plain, target: self, action: nil)
    return button
    }()
    
    lazy var doneBtn: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: nil)
    return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = "관리"
        self.navigationItem.rightBarButtonItems = [addBtn, doneBtn]
        
        bindViewModel()
        registerCell()
        setupUI()
    }
    
    func setupUI() {
        calendar.delegate = self
        calendar.dataSource = self
        
        todoView.layer.cornerRadius = 40
        todoView.layer.borderWidth = 0.4
        todoView.layer.borderColor = UIColor.black.cgColor
        
        CalendarViewModel.loadTodo.bind(to: todoTableView.rx.items(cellIdentifier: "todoCell", cellType: TodoTableViewCell.self)) { row, item, cell in
            print(item)
            cell.nameLabel.text = item.nickname
            cell.dataLabel.text = item.date
            cell.todoLabel.text = item.todo
        }.disposed(by: rx.disposeBag)
        
        
        addBtn.rx.tap.subscribe(onNext: { _ in
            self.todoAlert()
        }).disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
        let input = CalendarViewModel.input(
            selectIndexPath: Driver.just(selectIndexPath),
            selectDate: todoDate.asDriver(onErrorJustReturn: ""),
            todoText: todoText.asDriver(onErrorJustReturn: ""),
            alertTap: alertDone.asDriver())
        let output = viewModel.transform(input)
        
    }
    
    func registerCell() {
       let nib = UINib(nibName: "TodoTableViewCell", bundle: nil)
        todoTableView.register(nib, forCellReuseIdentifier: "todoCell")
        todoTableView.rowHeight = 96
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

extension CalendarViewController: FSCalendarDelegateAppearance, FSCalendarDataSource {

    func calendar(_ calendar: FSCalendar,
                  shouldSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.formatter.locale = Locale(identifier: "ko_KR")
        calendar.formatter.dateFormat = "yy-mm-dd"
        let nameOfDate = calendar.formatter.string(from: date as Date)
        self.todoDate.accept(nameOfDate)
        print("nameOfDate",nameOfDate)
    }

    func todoAlert() {
        let alert = UIAlertController(title: "Add TodoList", message: "할 일을 적어주세요", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) { (action) in
            
            self.alertDone.accept(())
            self.todoText.accept(alert.textFields![0].text!)
        }
        let backAction = UIAlertAction(title: "Back", style: .cancel, handler: nil)
        
        alert.addAction(doneAction)
        alert.addAction(backAction)
        alert.addTextField { (textField) in
            textField.placeholder = "ex) 로그인 UI 짜기"
//            if textField.rx.text.orEmpty {
//                doneAction.isEnabled = false
//            }
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}

