//: A UIKit based Playground for presenting user interface
import AVFoundation
import Foundation
import PlaygroundSupport
import UIKit

let CellIdentifier = "Cell"

class TableViewController : UIViewController {
    var table:UITableView!
    var people = [String]()
    var parts = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stories Never Told"
        people = ["James Hart", "Gene Pugh"]
        parts = ["Childhood", "Training", "Service", "After the war to now"]
        table.register(partTableViewCell.self, forCellReuseIdentifier: CellIdentifier)

        table.dataSource = self
        table.delegate = self
    }
    
    override func loadView() {
        view = UIView()
        //Design table view layout
        table = UITableView()
        table.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)!, width: 375, height: UIScreen.main.bounds.height)
        
        view.addSubview(table)
        self.view = view
    }
}

extension TableViewController : UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return people[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // attempt to dequeue a cell
        var cell: partTableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? partTableViewCell
        cell.accessoryType = .disclosureIndicator
        if cell == nil {
            // none to dequeue – make a new one
            cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier) as? partTableViewCell
            cell?.accessoryType = .disclosureIndicator
        }
        
        
        // configure cell here
        let part = parts[indexPath.row]
        cell.textLabel?.text = part
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) as? partTableViewCell
            else { return }
        var headerText = tableView.headerView(forSection: indexPath.section)?.textLabel?.text
        var partText = cell.textLabel?.text
        let vc = StoriesViewController()
        vc.message = "Hello"
        vc.tT1 = "\(headerText!)"
        vc.tT2 = "\(partText!)"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

class partTableViewCell : UITableViewCell {
    var titleLabel: UILabel?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel =  UILabel()
        self.contentView.addSubview(titleLabel!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel!.frame = CGRect(x: 15, y: 5, width: self.contentView.frame.width, height: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class StoriesViewController : UIViewController {
    var message = ""
    var tT1 = ""
    var tT2 = ""
    var audioPlayer = AVAudioPlayer()
    var button = UIButton()
    var isPlaying: Bool = false
    var textView = UITextView()
    var progressLabel = UILabel()
    
    override func loadView() {
        title = "\(tT1)'s \(tT2)"
        view = UIView()
        view.backgroundColor = UIColor.white
        
        button.frame = CGRect(x:50, y:75, width: 200, height: 10)
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(manipulateFile), for: .touchUpInside)
        view.addSubview(button)
        
        textView.frame = CGRect(x: 0, y: 100, width: 375, height: UIScreen.main.bounds.height)
         textView.backgroundColor = .black
        textView.textColor = .white
        textView.isEditable = false

        self.textView.text = load(file: findFileName())
        textView.isUserInteractionEnabled = true
        view.addSubview(textView)
        
        
    }
    
    func findFileName() -> String{
        let name = tT1.replacingOccurrences(of: " ", with: "")
        var part = ""
        if tT2 == "After the war to now"{
            part = "After"
        } else {
            part = tT2
        }
        return "\(name)_\(part)"
    }
    
    @objc func manipulateFile(){
        let fileName = findFileName()
        let path = Bundle.main.path(forResource: fileName, ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            progressLabel.frame = CGRect(x: 200, y: 30, width: 200, height: 100)
            var time = String(format: "%02d:%02d", ((Int)((audioPlayer.duration))) / 60, ((Int)((audioPlayer.duration))) % 60)
            progressLabel.text = time
            view.addSubview(progressLabel)
            if(!isPlaying){
                audioPlayer.play()
                button.setTitle("Stop", for: .normal)
                isPlaying = true
            } else {
                audioPlayer.stop()
                button.setTitle("Play", for: .normal)
                isPlaying = false
            }
            
        } catch {
            // couldn't load file
            print("Error loading audio file")
        }
    }
    
    func load(file name: String) -> String {

        if let path = Bundle.main.path(forResource: name, ofType: "txt") {

            if let contents = try? String(contentsOfFile: path) {

                return contents

            } else {

                print("Error! - This file doesn't contain any text.")
            }

        } else {

            print("Error! - This file doesn't exist.")
        }

        return ""
    }
}

//Present the view controller in the Live View window
let tableViewController = TableViewController();
let nav = UINavigationController(rootViewController: tableViewController)
PlaygroundPage.current.liveView = nav
