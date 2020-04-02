//
//  DetailVC.swift
//  ArtBook
//
//  Created by cihanbas on 29.03.2020.
//  Copyright © 2020 cihanbas. All rights reserved.
//

import UIKit
import CoreData


class DetailVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var yearLabel: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    var choosenPainting = ""
    var paintingID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if choosenPainting != "" {
            saveBtn.isHidden = true
            let appDelegete = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegete?.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
            let idString = paintingID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context?.fetch(fetchRequest)
                if results!.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameLabel.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearLabel.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch  {
                print("Hello")
            }
            
        }
        else {
             saveBtn.isHidden = false
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        imageView.isUserInteractionEnabled = true
        let imageRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImg))
        imageView.addGestureRecognizer(imageRecognizer)
        // Do any additional setup after loading the view.
    }
    @objc func hideKeyboard(){
        view.endEditing(true)
        
        
    }
    @objc func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as! UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Painting", into: context)
        newPainting.setValue(nameLabel.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearLabel.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        do {
            try context.save()
            print("saved")
        } catch  {
            print("Hata")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
}
