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

class HomeViewController: ViewController<HomeViewModel,HomeNavigator> {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var emptyDataLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindCollectionView()
        binUi()
        bindViewModel()
    }

    override func setupUI() {
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
            configureCell: { _, collectionView, indexPath, cellViewModel in
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

                cell.config(cellViewModel, firstItem: isFirst, lastItem: isLast)
                cell.delegate = self

                cell.onCheckBoxTapped
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        if indexPath.section == 0 {
                            self.showAlert(
                                title: "Complete Task",
                                message:
                                    "Are you sure you have completed this task?",
                                buttonTitles: ["Cancel", "Yes"]
                            ) { index in
                                if index == 1 {
                                    self.viewModel.isLoading.accept(true)
                                    cellViewModel.updateTask(isCompleteBefore: cellViewModel.item.isComplete, indexPath: indexPath)
                                }
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
            .do(onNext: { [weak self] sections in
                guard let self = self else { return }
                let isAllEmpty = sections.allSatisfy { $0.items.isEmpty }
                
                if isAllEmpty {
                    self.emptyDataLabel.isHidden = false
                } else {
                    self.emptyDataLabel.isHidden = true
                }
            })
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)


        // Tap Cell
        Observable.zip(
            collectionView.rx.itemSelected,
            collectionView.rx.modelSelected(TodoItemViewModel.self)
        )
        .subscribe(onNext: { [weak self] indexPath, task in
            guard let self = self else { return }
            if indexPath.section == 0 {
                viewModel.pushDetail(task: task, indexPath: indexPath)
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
                viewModel.pushDetail()
            })
            .disposed(by: disposeBag)

    }

    func bindViewModel() {
        viewModel.isLoading.bind(to: self.isLoading).disposed(by: disposeBag)

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
                    self.viewModel.deleteTask(taskViewModel: item, indexPath: indexPath)
                }
            }
        } else {
            self.viewModel.deleteTask(taskViewModel: item, indexPath: indexPath)
        }
    }
}
