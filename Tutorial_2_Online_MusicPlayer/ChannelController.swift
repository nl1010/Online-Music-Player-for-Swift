//
//  ChannelControl.swift
//  Tutorial_2_Online_MusicPlayer
//
//  Created by Edward Lucas on 9/20/14.
//  Copyright (c) 2014 Yan. All rights reserved.
//
import UIKit
import QuartzCore

class ChannelController:UIViewController,UITableViewDataSource,UITableViewDelegate {
    /*Step 4:connect elements from story board*/
    @IBOutlet weak var ChannelTableView: UITableView!
    
    
    /*Step 7:channel display*/
    var channelArray = NSArray()
    
    /*Step 8 : use delegate pass the data*/
    var viewControllerDelegate : MakeChannelChangeProtocol?
    
    
    //***UIViewController override ***
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            println("ChannelViewController has been successfully loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //***UITableViewDataSource protocal override***
    //numberOfRowInSection : how many rows need to be displayed
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return channelArray.count   //显示10行
    }
    
    //cellForRowAtIndexPath : when select each row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
    let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")  //identifier 从storyboard找到
        let songsDictionary = channelArray[indexPath.row] as NSDictionary
        cell.textLabel?.text = songsDictionary["name"] as? String
        return cell
    }

        
    
    //***UITableViewDelegateoverride***
    //didSelectRowAtIndexPath: what to do after we selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        // chap 9 ,callback,after select cell,inform,viewController update himself
        /*get channel_id*/
        let channelDictonary = self.channelArray[indexPath.row] as NSDictionary
        let channelId:AnyObject = channelDictonary["channel_id"] as AnyObject!
        let channelSubAddr = "channel=\(channelId)"  //convert channelid to channel=1,2,3,4 style for the usage of onSearch(url)
        //when we transfer channelSubbAddr, at the mean time we call viewController run makeChannelChange function
        self.viewControllerDelegate?.makeChannelChange(channelSubAddr)
        
        
        self.dismissViewControllerAnimated(true, nil) //close channelController --> go back to the main viewController
    }

    
    /*willDisplayCell: for cell display animation custimaize */
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5,1.0)
        UIView.animateWithDuration(0.2, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.0, 1.0,1.0)
            
        })
    }
    
    
    

}