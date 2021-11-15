//
//  APIManager.swift
//  OnlineProducts
//
//  Created by Mac on 22/10/21.
//

import Foundation

class APIManager {
    
    typealias complisherHandler = (_ products: [Product])->()
    typealias failure = (_ mssg: String)->()
    
    func getDataFromAPI(_ apiString: String, failureClosure: @escaping failure, productsClosure : @escaping complisherHandler){
        var productsArray = [Product]()
        if let url = URL(string: apiString) {
            let session = URLSession(configuration: .default)
            let dataTask = session.dataTask(with: url) { (dataFromServer, responce, error) in
                guard let data = dataFromServer else {
                    failureClosure("No internet!")
                    print("Error while getting data From server!!!")
                    return
                }
                do {
                    let products = try JSONDecoder().decode([Product].self, from: data)
                    productsArray = products
                    productsClosure(productsArray)
                } catch let InvalidDataError {
                    print(InvalidDataError.localizedDescription)
                }
            }
            dataTask.resume()
        } else {
            print("Invalid API URL!!!")
        }
    }
}
