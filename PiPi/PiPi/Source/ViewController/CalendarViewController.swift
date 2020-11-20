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
    private var successTodo = BehaviorRelay<Int>(value: 0)
    
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
            cell.nameLabel.text = item.nickname
            cell.dataLabel.text = item.date
            cell.todoLabel.text = item.todo
            
            cell.checkBtn.rx.tap.subscribe(onNext: { _ in
                self.successTodo.accept(row)
            }).disposed(by: self.rx.disposeBag)
        }.disposed(by: rx.disposeBag)
        
        addBtn.rx.tap.subscribe(onNext: { _ in
            self.todoAlert()
        }).disposed(by: rx.disposeBag)
        
        doneBtn.rx.tap.subscribe(onNext: { _ in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "finishVC") as? FinishViewController else { return }
            vc.selectIndexPath = self.selectIndexPath
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
        let input = CalendarViewModel.input(
            selectIndexPath: Driver.just(selectIndexPath),
            selectDate: todoDate.asDriver(onErrorJustReturn: ""),
            todoText: todoText.asDriver(onErrorJustReturn: ""),
            alertTap: alertDone.asDriver(),
            successTodo: successTodo.asDriver())
        let output = viewModel.transform(input)
        
        output.success.emit(onCompleted: {
            //해당 인덱스 삭제
            self.todoTableView.reloadData()
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
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            // remove the item from the data model
            
            // delete the table view row
            todoTableView.deleteRows(at: [indexPath], with: .fade)
            todoTableView.reloadData()
        }
    }
}
