//
//  ProductDetailsViewController.swift
//  OnlineProducts
//
//  Created by Mac on 22/10/21.
//

import UIKit

protocol ProductDetailsViewControllerProtocol: AnyObject {
    func updatedRow(row: Int?)
}

class ProductDetailsViewController: UIViewController {
    //
    //MARK: outlets
    //
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    weak var delegate: ProductDetailsViewControllerProtocol?
    var product: Product?
    var row: Int?
    var controlFromAPIPage: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product Info"
        setData()
        if controlFromAPIPage == false {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteBtnAction))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "WishList", style: .plain, target: self, action: #selector(wishListBtnAction))
        }
    }
    
    private func setData() {
        guard let product = product else {
            return
        }
        productImg.load(urlString: product.image)
        titleLabel.text = product.title
        priceLabel.text = String(product.price)
        descriptionLabel.text = product.description
        categoryLabel.text = product.category
        rateLabel.text = String(product.rating.rate)
        countLabel.text = String(product.rating.count)
    }
    
    private func showAlert(title: String, mssg: String, _ navigateBack: Bool = false){
        let alert = UIAlertController(title: title, message: mssg, preferredStyle: .alert)
        if navigateBack {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.delegate?.updatedRow(row: self.row)
                self.navigationController?.popToRootViewController(animated: true)
            }))
        }else {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func deleteBtnAction() {
        guard let product = product else {
            return
        }
        DBHelper().deleteProduct(id: product.id) { (title, mssg) in
            showAlert(title: title, mssg: mssg, true)
        } failureClosure: { (title, mssg) in
            showAlert(title: title, mssg: mssg)
        }
    }
    
    @objc private func wishListBtnAction() {
        guard let product = product else {
            return
        }
        DBHelper().insertValuesInProducts(product: product) { (title, mssg) in
            showAlert(title: title, mssg: mssg)
        } failureClosure: { (title, mssg) in
            showAlert(title: title, mssg: mssg)
        }
    }
}
//
//MARK: UIImageView
//
extension UIImageView {
    
    func load(urlString : String) {
        guard let url = URL(string: urlString)else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

