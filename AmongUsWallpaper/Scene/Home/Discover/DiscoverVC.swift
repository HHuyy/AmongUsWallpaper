//
//  DiscoverVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit

struct DiscoverCellModel {
    var imageName: String
    var labelName: String
}

class DiscoverVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: [DiscoverCellModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "DiscoverCell", bundle: .main), forCellReuseIdentifier: "DiscoverCell")
        data = [DiscoverCellModel(imageName: "AU-discover-cell-pic", labelName: "Among Us")]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension DiscoverVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath) as? DiscoverCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.nameLabel.text = data[indexPath.row].labelName
        cell.imageTheme.image = UIImage(named: data[indexPath.row].imageName)
        return cell
    }
    

    
}

extension DiscoverVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            NotificationCenter.default.post(name: .goToAU, object: nil)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
