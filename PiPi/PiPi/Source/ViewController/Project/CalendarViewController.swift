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

    private let viewModel = CalendarViewModel()
    private var todoDate = PublishRelay<String>()
    private var alertDone = BehaviorRelay<Void>(value: ())
    private var todoText = BehaviorRelay<String>(value: "")
    private var successTodo = PublishRelay<Int>()
    private var deleteTodo = BehaviorRelay<Int>(value: 0)

    var selectIndexPath = Int()
    var currentDate = String()
    
    lazy var addBtn: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Add", style: .plain, target: self, action: nil)
    return button
    }()
    
    lazy var doneBtn: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: nil)
    return button
    }()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        calendar.appearance.headerDateFormat = "YYYY년 M월"

        navigationController?.navigationBar.topItem?.title = "관리"
        navigationItem.rightBarButtonItems = [addBtn, doneBtn]
        navigationController?.isNavigationBarHidden = false

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
            cell.nameLabel.text = item.nickname
            cell.dataLabel.text = item.date
            cell.todoLabel.text = item.todo
            
            if item.todoStatus == "CHECK"{
                cell.checkBtn.tintColor = UIColor().hexUIColor(hex: "61BFAD")
            }else{
                cell.checkBtn.tintColor = UIColor.red
            }
            
            cell.checkBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
                successTodo.accept(row)
            }).disposed(by: self.rx.disposeBag)
            
        }.disposed(by: rx.disposeBag)
        
        addBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            todoAlert()
        }).disposed(by: rx.disposeBag)
        
        doneBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "finishVC") as? FinishViewController else { return }
            vc.selectIndexPath = selectIndexPath
            self.present(vc, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
        let input = CalendarViewModel.input(
            selectIndexPath: Driver.just(selectIndexPath),
            selectDate: todoDate.asDriver(onErrorJustReturn: ""),
            todoText: todoText.asDriver(onErrorJustReturn: ""),
            alertTap: alertDone.asDriver(),
            successTodo: successTodo.asDriver(onErrorJustReturn: 0))
        let output = viewModel.transform(input)
        
        output.result.emit(onCompleted: {[unowned self] in
            todoTableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.success.emit(onNext: {[unowned self] _ in
            todoDate.accept(currentDate)
            todoTableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.todo.emit(onCompleted: {[unowned self] in
            todoTableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.enter.emit(onNext: {[unowned self] _ in
            todoDate.accept(currentDate)
            todoTableView.reloadData()
        }).disposed(by: rx.disposeBag)
    }
    
    func registerCell() {
       let nib = UINib(nibName: "TodoTableViewCell", bundle: nil)
        todoTableView.register(nib, forCellReuseIdentifier: "todoCell")
        todoTableView.rowHeight = 96
    }
    
    func todoAlert() {
        let alert = UIAlertController(title: "Add TodoList", message: "할 일을 적어주세요", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) { (action) in
            print(alert.textFields![0].text!)
            self.todoText.accept(alert.textFields![0].text!)
            self.alertDone.accept(())
        }
        let backAction = UIAlertAction(title: "Back", style: .cancel, handler: nil)
        
        alert.addAction(doneAction)
        alert.addAction(backAction)
        alert.addTextField { (textField) in
            textField.placeholder = "ex) 로그인 UI 짜기"
        }
        self.present(alert, animated: true, completion: nil)
    }
}

extension CalendarViewController: FSCalendarDelegateAppearance, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar,
                  shouldSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let date_string = dateFormatter.string(from: date)
        todoDate.accept(date_string)
        currentDate = date_string
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            todoTableView.deleteRows(at: [indexPath], with: .fade)
            todoTableView.reloadData()
        }
    }
}
