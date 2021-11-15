//
//  HomeViewController.swift
//  OnlineProducts
//
//  Created by Mac on 22/10/21.
//
/*
 Program - take switch button for getting data from database and API "https://fakestoreapi.com/products" and perform operations respectively use collectionview to display data also display all details of product on another page and add product to database button on same page
 */
import UIKit

class HomeViewController: UIViewController {
    //
    //MARK: outlets
    //
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var switchBtnOutlet: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var products = [Product]()
    var controlFromAPIPage: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home Page"
        switchBtnAction(UISwitch())
        addLayout()
        self.activityIndicator.hidesWhenStopped = true
    }
    
    private func addLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 0)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        productsCollectionView?.collectionViewLayout = layout
    }
    
    private func showAlert(title: String, mssg: String, _ isAPIfailedAlert: Bool = false){
        let alert = UIAlertController(title: title, message: mssg, preferredStyle: .alert)
        if isAPIfailedAlert {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.stopAnimating()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        present(alert, animated: true, completion: nil)
    }
    //
    //MARK: switchBtnAction
    //
    @IBAction func switchBtnAction(_ sender: Any) {
        if switchBtnOutlet.isOn{
            self.productsCollectionView.isHidden = true
            if let products = DBHelper().displayProducts() {
                if products.count > 0 {
                    self.products = products
                    self.productsCollectionView.isHidden = false
                    self.controlFromAPIPage = false
                    self.productsCollectionView.reloadData()
                } else {
                    showAlert(title: "Warning", mssg: "Add products in wishlist first!!!")
                }
            } else {
                print("Nil value obtained from product table")
            }
        }else{
            productsCollectionView.isHidden = true
            activityIndicator.startAnimating()
            let apiString = "https://fakestoreapi.com/products"
            APIManager().getDataFromAPI(apiString,failureClosure: { (mssg) in
                DispatchQueue.main.async {
                    self.showAlert(title: "Warning", mssg: "Please check your Internet and try again!", true)
                }
            }) { (products) in
                self.products = products
                self.controlFromAPIPage = true
                DispatchQueue.main.async {
                    self.productsCollectionView.isHidden = false
                    self.productsCollectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidesWhenStopped = true
                }
            }
        }
    }
}
//
//MARK: UICollectionViewDataSource
//
extension HomeViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let product = products[indexPath.row]
        if let cell = productsCollectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as? ProductCell {
            cell.productTitleLabel.text = product.title
            cell.productPriceLabel.text = String(product.price)
            return cell
        }else{
            return UICollectionViewCell()
        }
    }
}
//
//MARK: UICollectionViewDelegateFlowLayout
//
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width-20
        let height = CGFloat(200)
        return CGSize(width: width, height: height)
    }
}
//
//MARK: UICollectionViewDelegate
//
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        if let productDetailsViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            productDetailsViewControllerObj.product = product
            productDetailsViewControllerObj.controlFromAPIPage = controlFromAPIPage
            productDetailsViewControllerObj.row = indexPath.row
            productDetailsViewControllerObj.delegate = self
            navigationController?.pushViewController(productDetailsViewControllerObj, animated: true)
        } else {
            print("Unable to find ProductDetailsViewController in storyboard!!!")
        }
    }
}
//
//MARK: ProductDetailsViewControllerProtocol
//
extension HomeViewController: ProductDetailsViewControllerProtocol {
    func updatedRow(row: Int?) {
        guard let row = row else {
            return
        }
        self.products.remove(at: row)
        self.productsCollectionView.reloadData()
    }
}
