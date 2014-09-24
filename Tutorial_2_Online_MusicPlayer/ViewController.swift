//
//  ViewController.swift
//  Tutorial_2_Online_MusicPlayer
//
//  Created by Edward Lucas on 9/19/14.
//  Copyright (c) 2014 Yan. All rights reserved.
//

//main view Controller
/*inherience 3 classed：UIViewController(exist as defualt），UITableViewDataSource,UITableViewDelegate
*/
import UIKit
import MediaPlayer
import QuartzCore //animation pack
class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HttpProtocol,MakeChannelChangeProtocol {
    
    /*step 4 : connect elements from story board*/
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var playTime: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var baiduTableView: UITableView!
    
    /*httpController's delegate */
    var httpController:HttpController = HttpController()
    
    var baiduArray = NSArray()
    var channelArray = NSArray()
    /*Step 6 img buffer*/
    var imgCache = Dictionary<String,UIImage>()
    
    /*step 8 play */
    var mediaPlayer:MPMoviePlayerController = MPMoviePlayerController()
    /*step 11 progress bar */
    var refreshTimer = NSTimer()
    
    /*Step 12 : tap gesture*/
    @IBOutlet weak var tapButton: UIImageView!

    @IBOutlet var tapOutlet: UITapGestureRecognizer!
    
    @IBAction func tapAction(sender: AnyObject) {
        if sender.view == tapButton {
            
            self.tapButton.hidden = true
            self.tapButton.removeGestureRecognizer(tapOutlet)
            
            self.mediaPlayer.play()
            self.imgView.addGestureRecognizer(tapOutlet)
        }else if sender.view == imgView {
            self.imgView.removeGestureRecognizer(tapOutlet)
            self.mediaPlayer.pause()
            
            self.tapButton.hidden = false
            self.tapButton.addGestureRecognizer(tapOutlet)

        }
    }
    /*===========Aux Function============*/
    func setUpAudioPlayer (url:String) {
        self.refreshTimer.invalidate()
        let refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector:"updateProgressBar", userInfo: nil, repeats: true)
        mediaPlayer.stop()  //stop previous songs
        
        self.imgView.addGestureRecognizer(tapOutlet)
        self.tapButton.hidden = true
        
        self.playTime.text = "00:00"  //zero the playTime
        self.progressBar.progress = 0.0 //zero the progressBar progress before playing
        mediaPlayer.contentURL = NSURL(string: url) //force cast url to NSURL type
        mediaPlayer.play() //automatically start playing song address just setted
        //self.refreshTimer.fire() //not sure if I need this
    }
    
    func updateProgressBar () {
        let currentPlayingTime = self.mediaPlayer.currentPlaybackTime
        let songDuration = self.mediaPlayer.duration
        if currentPlayingTime > 0.0  {  //>0.0 means media player start playing
            self.progressBar.setProgress(CFloat(currentPlayingTime / songDuration), animated: true)
            
            /*set time display*/
            let minitesDigit:Int = Int(currentPlayingTime/60)
            let secondsDigit:Int = Int(currentPlayingTime%60)
            var resultTimeText:String = ""
            if minitesDigit<10 {
                if secondsDigit < 10 {
                    resultTimeText="0\(minitesDigit):0\(secondsDigit)"
                }else {
                    resultTimeText="0\(minitesDigit):\(secondsDigit)"
                }
            }else {
                if secondsDigit < 10 {
                    resultTimeText="\(minitesDigit):0\(secondsDigit)"
                }else {
                    resultTimeText="\(minitesDigit):\(secondsDigit)"
                }
            }
            playTime.text  = resultTimeText
        }
        
        
    }
    
    //try get the img from buffer
    func setUpImg (url:String) {
        
        let img = imgCache[url] as UIImage?
        if img == nil {
            let nsURL = NSURL (string: url)
            let request = NSURLRequest (URL: nsURL)
            NSURLConnection.sendAsynchronousRequest(
                request,
                queue: NSOperationQueue.mainQueue(),
                completionHandler: {
                    (response,data,error) -> Void in
                    let img = UIImage (data:data)
                    self.imgView.image = img
                    self.imgCache[url] = img
            })
        } else {
            self.imgView.image = img
        }
    }
    
    
    
    
    
    
    
    /*============UIViewController Override===================*/
    /*viewDidLoad():what we do immediate after loaded?*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var baiduURL = "http://douban.fm/j/mine/playlist?channel=0"
        var channelURL = "http://www.douban.com/j/app/radio/channels"
        
  
        httpController.viewControllerDelegate = self
        httpController.onSearch(baiduURL)
        httpController.onSearch(channelURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*override prepareForSegue: what should we prepared before doing segue? all works which need to be transfered to other page need to be transfered in here */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        var channelController = segue.destinationViewController as ChannelController
        channelController.channelArray = channelArray
        
        /*======step 8 callback=========*/
        channelController.viewControllerDelegate = self 
        
    }
    
    
    
    
    
    
    
    /*============UITableViewDataSource override==============*/
    /*numberOfRowInSection*/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       // return 10   //显示10行
        return self.baiduArray.count
    }
    
    
    /*cellForRowAtIndexPath
    
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "baidu")  //identifier 从storyboard找到
        
        /*the dictionary which store each song's json information*/
        let songDictionary = self.baiduArray[indexPath.row] as NSDictionary
        cell.textLabel?.text = (songDictionary["title"] as String)
        cell.detailTextLabel?.text = (songDictionary["artist"] as String)
        

        
        let cellImgAddr = songDictionary["picture"] as String
        
        let img = imgCache[cellImgAddr] as UIImage?
        
        if img == nil {
            let nsURL = NSURL (string: cellImgAddr)
            let request = NSURLRequest (URL: nsURL)
            NSURLConnection.sendAsynchronousRequest(
                request,
                queue: NSOperationQueue.mainQueue(),
                completionHandler: {
                    (response,data,error) -> Void in
                    let img = UIImage (data:data)
                    cell.imageView?.image = img
                self.imgCache[cellImgAddr] = img
            })
        } else {
            cell.imageView?.image = img
        }
        return cell
    }
    
    /*============ UITableViewDelegate override ===================*/
    
    /*==didSelectRowAtIndexPath==
    step 8 play*/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){

        let songDictionary = self.baiduArray[indexPath.row] as NSDictionary
        let songUrl = songDictionary["url"] as String
        setUpAudioPlayer(songUrl)

        let songImgUrl = songDictionary["picture"] as String
        setUpImg(songImgUrl)
    }

    
    
    /*willDisplayCell: for cell display animation custimaize */
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.2, 0.2,0.2)
        UIView.animateWithDuration(0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.0, 1.0,1.0)

        })
    }
    
    
    
    
    
    
    /*HttpProtocol override*/
    func didReResults(resultData:NSDictionary){
    
         println("didReResults in ViewController has been reached")
        

        if (resultData["song"] != nil){
            self.baiduArray = resultData["song"] as NSArray
            self.baiduTableView.reloadData()
            
        
            let firstSongDictionary = self.baiduArray[0] as NSDictionary
            let firstSongUrl = firstSongDictionary["url"] as String
            setUpAudioPlayer(firstSongUrl)

            let firstSongImgUrl = firstSongDictionary["picture"] as String
            setUpImg(firstSongImgUrl)

            
        }else if (resultData["channels"] != nil){
            self.channelArray = resultData["channels"] as NSArray
        }
    }
    
    
    
    
    /*MakeChannelChangesProtocol override */
    
    func makeChannelChange(channelAddr: String) {
            //receive the new channel adderess ,update the original http address and recall onSearch method to get new songs in that channel 
            //channel url
            //....ine/playlist?channel=0  .......ine/playlist?channel=1 , channel=0  , channel=1 is the channel address
        println(channelAddr)
        var updatedUrl = "http://douban.fm/j/mine/playlist?\(channelAddr)"
        println(updatedUrl)
        
        
        httpController.onSearch(updatedUrl)
    }

}

