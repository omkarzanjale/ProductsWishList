//
//  DBHelper.swift
//  OnlineProducts
//
//  Created by Mac on 24/10/21.
//

import Foundation
import SQLite3

class DBHelper {
    private var db: OpaquePointer?
    init() {
        self.db = createAndOpenDatabase()
        createProductsTable()
    }
    
    private func createAndOpenDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        let dbName = "Products.sqlite"
        do {
            let docDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dbName)
            if sqlite3_open(docDirectory.path, &db) == SQLITE_OK{
                print("Database created and opned successfully.")
                print("Database path \(docDirectory.path)")
                return db
            }else{
                print("Database already created opned successfully.")
                return db
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }

    private func createProductsTable(){
        var createTableStatement: OpaquePointer?
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Products(id INTGER PRIMARY KEY,title TEXT,price DOUBLE, description TEXT,category TEXT,image TEXT,rate DOUBLE,count INTEGER)"
        
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK{
            if sqlite3_step(createTableStatement) == SQLITE_DONE{
                print("Products table successfully created..")
            }else{
                print("Products table already exist!!!")
            }
        }else{
            print("Unable to prepare Products create table statement!!")
        }
    }//createUserTable function end
    //
    //MARK: insertValuesInProducts
    //
    typealias successfullyInsert = (_ title: String, _ msg: String) -> Void
    typealias failureInsert = (_ title: String, _ msg: String) -> Void
    
    func insertValuesInProducts(product:Product,successClosure: successfullyInsert, failureClosure: failureInsert){
        var insertStatement: OpaquePointer?
        let insertQuery = "INSERT INTO Products(id,title,price,description,category,image,rate,count) VALUES(?,?,?,?,?,?,?,?)"
        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK{
            let idInt32 = Int32(product.id)
            sqlite3_bind_int(insertStatement, 1, idInt32)
            
            let titleNS = product.title as NSString
            let titleText = titleNS.utf8String
            sqlite3_bind_text(insertStatement, 2, titleText, -1, nil)
            
            sqlite3_bind_double(insertStatement, 3, product.price)
            
            let descText = (product.description as NSString).utf8String
            sqlite3_bind_text(insertStatement, 4, descText, -1, nil)
            
            let categoryText = (product.category as NSString).utf8String
            sqlite3_bind_text(insertStatement, 5, categoryText, -1, nil)
            
            let imageText = (product.image as NSString).utf8String
            sqlite3_bind_text(insertStatement, 6, imageText, -1, nil)
            
            sqlite3_bind_double(insertStatement, 7, product.rating.rate)
            
            let countInt32 = Int32(product.rating.count)
            sqlite3_bind_int(insertStatement, 8, countInt32)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE{
                successClosure("Successfull", "Added to wishlist.")
            }else{
                failureClosure("Warning", "Already added in wishlist.")
            }
        }else{
            failureClosure("Warining","Unable to add in wishlist! try again!")
        }
        sqlite3_finalize(insertStatement)
    }//insertValuesInUser func end
    //
    //MARK: deleteProduct
    //
    typealias successfullyDelete = (_ title: String, _ msg: String) -> Void
    typealias failureDelete = (_ title: String, _ msg: String) -> Void
    func deleteProduct(id: Int, succesClosure: successfullyDelete, failureClosure: failureDelete) {
        var deleteStatement: OpaquePointer?
        let query = "DELETE FROM Products WHERE id = '\(id)'"
        
        if sqlite3_prepare_v2(db, query, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                succesClosure("Success","Product removed from wishList.")
            } else {
                failureClosure("warning","Unable to delete! Try again.")
            }
        } else {
            print("Unable prepare delete query!!!")
        }
    }
    //
    //MARK: displayProducts
    //
    func displayProducts() -> [Product]? {
        var selectStatement: OpaquePointer?
        let selectQuery = "SELECT * FROM Products"
        var products = [Product]()
        
        if sqlite3_prepare_v2(db,selectQuery, -1, &selectStatement, nil) == SQLITE_OK{
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(selectStatement, 0))
                guard let title_CStr = sqlite3_column_text(selectStatement, 1) else{
                    print("Error while getting title from db!!!")
                    continue
                }
                let title = String(cString: title_CStr)
                
                let price = sqlite3_column_double(selectStatement, 2)
                
                guard let desc_CStr = sqlite3_column_text(selectStatement, 3) else {
                    print("Error while getting desc from db!!!")
                    continue
                }
                let description = String(cString: desc_CStr)
                
                guard let category_CStr = sqlite3_column_text(selectStatement, 4) else {
                    print("Error while getting category from db!!!")
                    continue
                }
                let category = String(cString: category_CStr)
                
                guard let img_CStr = sqlite3_column_text(selectStatement, 5) else {
                    print("Error while getting img name from db!!!")
                    continue
                }
                let img = String(cString: img_CStr)
                
                let rate = sqlite3_column_double(selectStatement, 6)
                
                let count = Int(sqlite3_column_int(selectStatement, 7))
                
                let product = Product(id: id, title: title, price: price, description: description, category: category, image: img, rating: Rating(rate: rate, count: count) )
                products.append(product)
            }
            sqlite3_finalize(selectStatement)
            return products
        }else{
            print("Unable to prepare select query!!!")
        }
        sqlite3_finalize(selectStatement)
        return nil
    }//displayUsers func end
}//class end
