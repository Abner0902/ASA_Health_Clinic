//
//  BookingContainerViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 16/6/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import CoreData
import Eureka

class BookingContainerViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource, AddBookingDelegate, UpdateBookingDelegate, SetFilterDelegate {
    
    @IBOutlet weak var addBookingButton: UIButton!
    
    var appDelegate: AppDelegate!
    var managedObjectContext: NSManagedObjectContext
    var bookings: NSMutableArray
    var filteredBookings = [Booking]()
    var fileterActive = false
    var filterOption = 2
    //let btnFilter = UIButton(type: .system)
    
    @IBOutlet weak var bookingTableView: UITableView!
    
    //initializer
    required init?(coder aDecoder: NSCoder) {
        managedObjectContext = ManagedContext().getManagedObject()
        bookings = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = ManagedContext().getManagedObject()
        // Do any additional setup after loading the view.
        
        self.loadFilterForm()
        
        bookingTableView.tableFooterView = UIView()
        bookingTableView.dataSource = self
        bookingTableView.delegate = self
    }
    
    func loadFilterForm() {
        
//        
//        btnFilter.frame =  CGRect(x: 6, y: 0, width: 100, height: 30)
//        //btnFilter.tintColor = UIColor.black
//        btnFilter.setImage(UIImage(named:"filter.png"), for: .normal)
//        btnFilter.imageEdgeInsets = UIEdgeInsets(top: 3,left: 60,bottom: 2,right: 10)
//        btnFilter.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 80)
//        btnFilter.setTitle("Filter", for: .normal)
//
//        //btnFilter.layer.borderWidth = 1.0
//        //btnFilter.backgroundColor = UIColor.red //--> set the background color and check
//        //btnFilter.layer.borderColor = UIColor.white.cgColor
//        btnFilter.addTarget(self, action: #selector(BookingContainerViewController.showFilterOptions), for: UIControlEvents.touchUpInside)
//        self.view.addSubview(btnFilter)
    }
//    
//    func showFilterOptions() {
//        
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if detailItem != nil {
            //fetch all bookings in the array
            bookings.addObjects(from: (detailItem?.has?.allObjects)!)
            //sort the array
            let sortDescriptor = NSSortDescriptor (key: "dateTime" , ascending: true)
            bookings.sort(using: [sortDescriptor])
            filteredBookings = filteredBookings.sorted(by: { $0.dateTime! as Date > $1.dateTime! as Date})
            //enable the add button
            addBookingButton.isEnabled = true
            //btnFilter.isEnabled = true
        } else {
            addBookingButton.isEnabled = false
            //btnFilter.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var detailItem: Patient? {
        didSet {
            // Update the view.
            //configureView()
        }
    }
    // Mark: Delegate Methods
    //Update booking method
    func updateBooking(doctor: String, clinic: String, date: Date, clinic_ph: String, bookingToUpdate: Booking, rowToUpdate: IndexPath) {
        
        bookingToUpdate.setValue(doctor, forKey: "doctor")
        bookingToUpdate.setValue(clinic, forKey: "clinic_add")
        bookingToUpdate.setValue(date as NSDate, forKey: "dateTime")
        bookingToUpdate.setValue(clinic_ph, forKey: "clinic_ph")
        
        //Save the ManagedObjectContext
        do {
            updateBookingInFireBase()
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        //set up the sms reminder
        updateSMSReminder()
        configureCell(bookingTableView.cellForRow(at: rowToUpdate) as! BookingTableViewCell, withBooking: bookingToUpdate)
    }
    
    //update booking in firebase
    func updateBookingInFireBase() {
        
    }
    
    // AddBooking delegate method
    func addBooking(doctor: String, clinic: String, date: Date, clinic_ph: String) {
        //add booking to core data here
        let newBooking = NSEntityDescription.insertNewObject(forEntityName: "Booking", into: managedObjectContext) as? Booking
        //configure the new booking
        newBooking?.dateTime = date as NSDate
        newBooking?.clinic_add = clinic
        newBooking?.doctor = doctor
        newBooking?.clinic_ph = clinic_ph.substring(to: clinic_ph.index(clinic_ph.startIndex, offsetBy: 10))
        newBooking?.status = false
        newBooking?.sms = false
        
        self.detailItem?.addToHas(newBooking!)
        
        //Save the ManagedObjectContext
        do {
            addBookingInFireBase()
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        //set up the sms reminder
        setupSMSReminder(booking: newBooking!)
        
        //add booking to table view
        bookings.add(newBooking!)
        let indexPath = IndexPath(row: bookings.count - 1, section: 0)
        bookingTableView.insertRows(at: [indexPath], with: .fade)
    }
    
    func addBookingInFireBase() {
        
    }
    
//    func getCellIndexPaths() -> [IndexPath] {
//        return (0..<bookingTableView.numberOfRows(inSection: 1)).map{IndexPath(row: $0, section: 1)}
//    }
    
    // Mark: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBookingSegue" {
                
            let destinationVC: AddBookingViewController = segue.destination as! AddBookingViewController
            destinationVC.delegate = self
        } else if segue.identifier == "editBookingSegue" {
            let destinationVC: UpdateBookingDetailViewController = segue.destination as! UpdateBookingDetailViewController
            destinationVC.delegate = self
            if let indexPath = bookingTableView.indexPathForSelectedRow {
                destinationVC.currentBooking = bookings.object(at: indexPath.row) as? Booking
                destinationVC.selectedRow = indexPath
            }
            
        }else if segue.identifier == "filterPopoverSegue" {
            let destinationVC: FilterViewController = segue.destination as! FilterViewController
            
            if let popoverPresentationController = segue.destination.popoverPresentationController, let sourceView = sender as? UIView {
                popoverPresentationController.sourceRect = sourceView.bounds
            }
            
            destinationVC.delegate = self
            destinationVC.option = self.filterOption
        }
    }
    
    // Mark: - Table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fileterActive {
            return filteredBookings.count
        }
        
        if detailItem == nil {
            return 0
        } else {
        
            if detailItem?.has?.count != 0 {
                    
                return (detailItem?.has?.count)!
            } else {
                    return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientBookingCell", for: indexPath) as! BookingTableViewCell
        
        //detect filter selection
        let booking: Booking
        if fileterActive {
            booking = filteredBookings[indexPath.row]
        } else {
            booking = bookings[indexPath.row] as! Booking
        }
        
        
        
        configureCell(cell, withBooking: booking)
        tableView.rowHeight = 70
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookingToRemove = bookings[indexPath.row]
            managedObjectContext.delete(bookingToRemove as! NSManagedObject)
            do {
                try managedObjectContext.save()
                bookings.remove(bookingToRemove)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "bookingHeaderCell") as! BookingHeaderCell
        if section == 0 {
            headerCell.backgroundColor = UIColor.lightGray
            headerCell.dateLabel.text = "Date"
            headerCell.doctorLabel.text = "Doctor"
            headerCell.addressLabel.text = "Clinic Address"
            headerCell.StatusLabel.text = "Status"
        }
        return headerCell
    }
    
    func configureCell(_ cell: BookingTableViewCell, withBooking booking: Booking) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        cell.dateLabel.text = dateFormatter.string(from: (booking.dateTime! as Date))
        let doctorString = booking.doctor!
        cell.doctorLabel.text = doctorString
        cell.addressLabel.text = booking.clinic_add
        cell.addressLabel.sizeToFit()
        cell.addressLabel.numberOfLines = 3
        
        if !booking.status {
            cell.StatusLabel.text = "Not Completed"
        } else {
            cell.StatusLabel.text = "Completed"
        }
    }
    
    //Mark: - SMS Reminder
    
    func setupSMSReminder(booking: Booking) {
        
        let message = self.createMessageContent(booking: booking)
        
        self.scheduleSMS(message: message)
    }
    
    func scheduleSMS(message: String) {
        let phoneStr = detailItem?.phone
        var todoEndpoint = ""
        if phoneStr?.substring(to: (phoneStr?.index((phoneStr?.startIndex)!, offsetBy: 3))!) == "852" {
            todoEndpoint = "https://api3.hksmspro.com/service/smsapi.asmx/SendSMS?Username=quadrinity&Password=quadrinity&Message=test&Hex=&Telephone=" + "\(detailItem?.phone ?? "")" + "&UserDefineNo=&Sender=&Subject=&Base64Attachments=&Filename=&MessageAt=0"
        } else {
            todoEndpoint = "https://api3.hksmspro.com/service/smsapi.asmx/SendSMS?Username=quadrinity&Password=quadrinity&Message=test&Hex=&Telephone=852" + "\(detailItem?.phone ?? "")" + "&UserDefineNo=&Sender=&Subject=&Base64Attachments=&Filename=&MessageAt=0"
        }
        
        
        let escapedURL = todoEndpoint.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        
        
        guard let url = URL(string: escapedURL!) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        // make the request
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            // do stuff with response, data & error here
            print(error as Any)
            print(response as Any)
            
//            let xmlParser = XMLParser()
            
            
        })
        task.resume()
    }
    
    func createMessageContent(booking: Booking) -> String {
        
        let bookingTime = booking.dateTime
        let doctorName = booking.doctor
        let clinicAddress = booking.clinic_add
        let clinicPhone = booking.clinic_ph
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-mm-dd HH:mm"
        
        let message = "你好! 我們是ASA物理治療中心。你的預約詳情如下：預約時間：\(dateFormater.string(from: bookingTime! as Date)) 醫生：\(doctorName ?? "") 診所地址：\(clinicAddress ?? "") 如想更改預約時間或有任何查詢，請電：\(String(describing: clinicPhone!))."
        
        
        NSLog("\(message)")
        return message
    }
    
    func updateSMSReminder() {
        
    }
    
    func setFilter(option: String) {
        //clear filter
        fileterActive = true
        filteredBookings.removeAll()
        
        var startDate = Date()
        var endDate = Date()
        
        switch option.lowercased() {
        case "all":
            fileterActive = false
            filterOption = 2
            break
        case "today":
            filterOption = 3
            break
        case "one week ago":
            startDate = Date().addingTimeInterval(-60*60*24*7)
            filterOption = 0
            break
        case "one month ago":
            startDate = Date().addingTimeInterval(-60*60*24*7*30)
            filterOption = 1
            break
        case "within one week":
            endDate = Date().addingTimeInterval(60*60*24*7)
            filterOption = 4
            break
        case "within one month":
            endDate = Date().addingTimeInterval(60*60*24*7*30)
            filterOption = 5
            break
        default:
            break
        }
        
        if fileterActive {
             addDataToFileredBooking(startDate: startDate, endDate: endDate)
        }
        
        bookingTableView.reloadData()
    }
    
    func addDataToFileredBooking(startDate: Date, endDate: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        for booking in bookings {
            let bookingDate = ((booking as! Booking).dateTime)! as Date
            
            if Calendar.current.isDateInToday(startDate) && Calendar.current.isDateInToday(endDate) && dateFormatter.string(from: bookingDate) == dateFormatter.string(from: startDate) {
                //the booking date is today
                filteredBookings.append(booking as! Booking)
            } else if(bookingDate >= startDate && bookingDate <= endDate) {
                //the booking date is in the specific time period
                filteredBookings.append(booking as! Booking)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
