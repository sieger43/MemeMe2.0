//
//  MemeTableViewController.swift
//  MemeMe2.0
//
//  Created by John Berndt on 12/10/18.
//  Copyright © 2018 Siegersoft. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {

    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)

        self.tableView.reloadData()
    }
    
    var memes: [Meme] {
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    
    /**
     * Number of Rows
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memes.count
    }
    
    /**
     * Cell For Row At Index Path
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let meme = memes[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell")
        cell!.textLabel?.text = meme.topText! + " " + meme.bottomText!
        cell!.imageView?.image = meme.memedImage
        
        return cell!
    }

    /**
     * didSelectRowAtIndexPath
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = self.memes[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)
        
    }
    
}
