//
//  ViewController.swift
//  Todo_App
//
//  Created by admin on 13/10/25.
//

import RxCocoa
import RxDataSources
import RxSwift
import SwipeCellKit
import UIKit

class HomeViewController: UIViewController {

    let disposeBag = DisposeBag()

    var viewModel: TaskViewModel!

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var addButton: UIButton!

    @IBOutlet weak var loadingUiView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUi()
        bindCollectionView()
        binUi()
        bindViewModel()
    }

    func setupUi() {
        view.backgroundColor = UIColor(
            red: 241 / 255,
            green: 245 / 255,
            blue: 249 / 255,
            alpha: 1
        )

        collectionView.rx.setDelegate(self).disposed(by: disposeBag)

        if let layout = collectionView.collectionViewLayout
            as? UICollectionViewFlowLayout
        {
            layout.itemSize = CGSize(
                width: collectionView.frame.width - 14,
                height: 80
            )
        }

        collectionView.backgroundColor = .clear

        viewModel.currentDate
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                self.setupTitleNavigation(date: date)
            })
            .disposed(by: disposeBag)

    }

    func bindCollectionView() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<TaskSection>(
            configureCell: { _, collectionView, indexPath, item in
                let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: "TodoItem",
                        for: indexPath
                    ) as! TodoItem

                let isFirst = indexPath.row == 0
                let isLast =
                    indexPath.row
                    == (self.viewModel.sections.value[indexPath.section].items
                        .count - 1)

                cell.config(task: item, firstItem: isFirst, lastItem: isLast)
                cell.delegate = self

                cell.onCheckBoxTapped
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        self.showAlert(
                            title: "Complete Task",
                            message:
                                "Are you sure you have completed this task?",
                            buttonTitles: ["Cancel", "Yes"]
                        ) { index in
                            if index == 1 {
                                self.viewModel.completeTask(task: item)
                            }
                        }
                    })
                    .disposed(by: cell.disposeBag)

                return cell
            },
            configureSupplementaryView: {
                dataSource,
                collectionView,
                kind,
                indexPath in
                let header =
                    collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: "HeaderLisst",
                        for: indexPath
                    ) as! HeaderList
                let title = dataSource.sectionModels[indexPath.section].header
                header.isHidden = title == nil
                header.headerTabel.text = title ?? ""
                return header
            }
        )

        viewModel.sections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // Tap Cell
        Observable.zip(
            collectionView.rx.itemSelected,
            collectionView.rx.modelSelected(Tasks.self)
        )
        .subscribe(onNext: { [weak self] indexPath, task in
            guard let self = self else { return }
            if indexPath.section == 0 {
                let vc =
                    storyBoard.instantiateViewController(
                        identifier: "DetailTaskScreen"
                    ) as! AddTaskViewCL
                vc.task = task

                vc.viewModel.dataOutput
                    .subscribe(onNext: { value in
                        guard let value = value else { return }
                        self.viewModel.updateData(task: value)
                    })
                    .disposed(by: vc.viewModel.disposeBag)

                self.navigationController?.pushViewController(
                    vc,
                    animated: true
                )
            } else {
                print(task.title)
            }
        })
        .disposed(by: disposeBag)

    }

    func binUi() {
        addButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                let vc =
                    storyBoard.instantiateViewController(
                        identifier: "DetailTaskScreen"
                    ) as! AddTaskViewCL

                vc.viewModel.dataOutput
                    .subscribe(onNext: { value in
                        guard let value = value else { return }
                        self.viewModel.updateData(task: value)
                    })
                    .disposed(by: vc.viewModel.disposeBag)

                self.navigationController?.pushViewController(
                    vc,
                    animated: true
                )
            })
            .disposed(by: disposeBag)

    }

    func bindViewModel() {
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                guard let error = error else { return }

                self.showAlert(title: error.title, message: error.message)
                print(error.message)

            })
            .disposed(by: disposeBag)

        viewModel.success
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                guard let self = self else { return }
                guard let success = success else { return }
                self.showAlert(title: "Success", message: success)

            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: loadingUiView.rx.isHidden)
            .disposed(by: disposeBag)

    }

    func setupTitleNavigation(date: Date) {
        let formatDate = DateFormatter()
        formatDate.dateFormat = "MMMM dd, yyyy"
        navigationItem.title = formatDate.string(from: date)
    }
    
    func handleDelete(at indexPath: IndexPath) {
        let current = viewModel.sections.value
        let item = current[indexPath.section].items[indexPath.item]
        
        if indexPath.section == 0 {
            self.showAlert(title: "Delete Task", message: "This task has not been completed. Are you sure you want to delete it?", buttonTitles: ["Cancel", "Yes"]){ index in
                if index == 1 {
                    self.viewModel.deleteTask(task: item)
                }
            }
        } else {
            self.viewModel.deleteTask(task: item)
        }
    }
}
