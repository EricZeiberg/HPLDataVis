//
//  ViewController.swift
//  HPLDataVis
//
//  Created by Eric Zeiberg on 2/22/20.
//  Copyright © 2020 University of Connecticut. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {

    @IBOutlet weak var xLineChart: LineChartView!
    
    @IBOutlet weak var connectingLabel: UILabel!
    
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var yLineChart: LineChartView!
    var lineChartEntry = [ChartDataEntry]()
    
    var bluetoothManager: BluetoothManager = BluetoothManager()
     
    var time = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothManager.startBluetooth()
       
        let nc = NotificationCenter.default
        nc.addObserver(forName: NSNotification.Name(rawValue: "DataReceived"), object: nil, queue: nil, using: updateGraph)
        // Do any additional setup after loading the view.
    }
    
    @objc public func updateGraph(notification:Notification) {
               
        guard let name = notification.userInfo!["value"] as? String  else { return }
        let trimmedString = name.replacingOccurrences(of: "\r\n", with: "")
        let value = Double(trimmedString)
        if (value != nil) {
            let valueX = ChartDataEntry(x: time, y: value!) // here we set the X and Y status in a data chart entry
                lineChartEntry.append(valueX)
        }
        
        time = time + 10

        let line1 = LineChartDataSet(entries: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the colour to blue

        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        

        xLineChart.data = data //finally - it adds the chart data to the chart and causes an update
        xLineChart.chartDescription?.text = "My awesome chart" // Here we set the description for the graph
        
    }
    
    public func setConnected() {
        
    }


}

