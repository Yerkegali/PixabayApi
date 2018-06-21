//
//  ViewController.swift
//  Pixabay Api Erke
//
//  Created by Yerkegali Abubakirov on 17.10.16.
//  Copyright © 2016 Yerkegali Abubakirov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pictureURLs : [String] = []
    var pictureTags : [String] = []
    
    var tagg = "text"
    
    override func viewDidLoad() {
        searchBar.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getPictures(query: String){
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = "https://pixabay.com/api/?key=3588547-45622bf326677af0e44312a7d&q=\(query!)&image_type=photo"
        print(url )
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, url, error) in
            if(error != nil){
                print(error?.localizedDescription)
            }
            else {
                let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                
                if let hits = json["hits"] as? [[String: AnyObject]]{
                self.pictureURLs = []
                self.pictureTags = []
             
                    for picture in hits {
                        
                    if let previewURL = picture["previewURL"] as? String {
                    self.pictureURLs.append(previewURL)
                        }
                    }
                    
                    for tagg in hits {
                        
                        if let tag = json["tag"] as? String{
                            self.pictureTags.append(tag)
                        }
                    
                    }
                    
                    
                    print("picture links are", self.pictureURLs)
                    
                    DispatchQueue.main.async{
                    
                        self.collectionView.reloadData()
                        
                    }
                    
                }
            }
        }.resume()
    }
}


extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.pictureURLs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.imageView.imageFromURL(urlString: self.pictureURLs[indexPath.row])
        cell.tagLabel.text = pictureTags[indexPath.row]
        
        return cell
    }

    
}


extension ViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text
        if text != nil {
            self.getPictures(query: text!)
        }
    }

}


extension UIImageView {
    
    public func imageFromURL(urlString: String){
        if let url = URL(string: urlString){
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if(error != nil){
                print(error?.localizedDescription)
                }
                else {
                    if let image = UIImage(data: data!){
                        DispatchQueue.main.async {
                            self.image = image
                        }
                    }
                }
            }).resume()
        }
    }
}
