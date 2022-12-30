//
//  ContactDetailViewController.swift
//  ContactApp
//
//  Created by Samreth Kem on 12/6/22.
//

import UIKit


class ContactDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var viewModel: ContactDetailViewControllerViewModelProtocol!
    private var updateButton: UIBarButtonItem!
    private var headerView: HeaderView!
    
    init(viewModel: ContactDetailViewControllerViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        let nib = UINib(nibName: "ContactDetailTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ContactDetailTableViewCell")
        tableView.dataSource = self
        tableView.sectionIndexColor = .black
        
        let profileGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfile))
        profileGesture.numberOfTapsRequired = 1
        
        let headerViewModel = HeaderViewModel()
        headerView = HeaderView(viewModel: headerViewModel)
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
        headerView.imageView.isUserInteractionEnabled = true
        headerView.imageView.addGestureRecognizer(profileGesture)
        if let profile = viewModel.getProfile() {
            headerView.imageView.image = UIImage(data: profile)
        }
        
        tableView.tableHeaderView = headerView
        
        updateButton = editButtonItem
        updateButton.tintColor = .systemBlue
        updateButton.action = #selector(edit)
        navigationItem.rightBarButtonItem = updateButton
    }
}

//MARK: actions
extension ContactDetailViewController {
    @objc func changeProfile() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true)
    }
    
    @objc func edit() {
        let addViewModel = AddViewModel(contactGroup: viewModel.getContactGroup(), contact: viewModel.contact, title: "EDIT") {[weak self] contact in
            self?.viewModel.editCallBack(contact)
            self?.viewModel.contact = contact
            self?.tableView.reloadData()
        }
        
        present(AddViewController(addViewModel: addViewModel), animated: true)
    }
}

//MARK: tableview datasource
extension ContactDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactDetailTableViewCell", for: indexPath) as? ContactDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = ContactDetailViewModel(title: viewModel.getTitle(index: indexPath.row), info: viewModel.getInfo(index: indexPath.row))
        
        cell.config(viewModel: cellViewModel)
        return cell
    }
}











//MARK: uiimagepicker delegate & datasource
extension ContactDetailViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            headerView.imageView.image = image
            viewModel.saveProfile(profile: image.jpegData(compressionQuality: 1))
        }
        
        picker.dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
